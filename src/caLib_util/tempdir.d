module caLib_util.tempdir;

import std.file : tempDir, mkdirRecurse, rmdirRecurse, exists, dirEntries, SpanMode, FileException;
import std.random : uniform;
import std.conv : to;
import std.path : buildNormalizedPath;
import std.exception : enforce;


private immutable string tempDirsRoot;

shared static this()
{
	if(tempDir() == ".")
		// if tempdir() returns "." it means that a temporary files root
		// could not be found. If this happens, we make on on our own
		tempDirsRoot = makeTempDirsRoot();
	else
		tempDirsRoot = tempDir();

	// If there is any temporary files this program left behind before
	// (this could happen if the program crashed). Remove them
	removeTempFiles();
}

shared static ~this()
{
	// Remove all the temporary files we created before exiting the program
	removeTempFiles();
}



/**
* Creates and return a path to a private, temporary directory
*
* This function can be used when data needs to be writen to and
* manipulated on the disk without worring about it being overwritten by other
* programs or the user. This directory will be destroyed when the program
* exits.
*
* Returns:
*     A path to a newly created temporary directory
*/
string makePrivateTempDir() { return makePrivateTempDir(0); }

private string makePrivateTempDir(int n)
{
	// we will only try to make a temporary directory 1000 times
	enforce(n < 1000,
		"Could not create a temporary directory");

	// path to the new temporary directory
	string dir = buildNormalizedPath(tempDirsRoot, "caLib3_",
		to!string(uniform(1000, 9999)));

	// if there already exists a directory in ths location
	//redo the entire proccess
	if(exists(dir))
		return makePrivateTempDir(n+1);

	// otherwise, make the directory and return the path to it
	mkdirRecurse(dir);
	return dir;
}



private void removeTempFiles()
{
	// if the temporary root directory is gone (it really shoulden't but its
	// not our responibility), all the temporary files created by uss are gone.
	// Just return
	if(!exists(tempDirsRoot))
		return;
	
	// list all the directories in the temporary files root
	auto dirs = dirEntries(tempDirsRoot, SpanMode.shallow);
	
	// iterate over the entries
	foreach(dirPath ; dirs)
	{
		string dirName = dirPath[tempDirsRoot.length .. dirPath.length];

		// if there is a entry starting with "caLib3_" ->
		// It was created by us -> remove the direcory
		if(dirName.length >= 7 && dirName[0 .. 7] == "caLib3_")
			rmdirRecurse(dirPath);
	}
}



private string makeTempDirsRoot()
{
	assert(0, "Can't create temporary file:" ~
		"This os has no location for temporary files");
}