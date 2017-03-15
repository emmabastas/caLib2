module caLib_util.tempdir;

import std.file : tempDir, mkdirRecurse, rmdirRecurse, exists, dirEntries, SpanMode, FileException;
import std.random : uniform;
import std.conv : to;
import std.path : absolutePath;
import std.exception : enforce;


private immutable string tempDirsRoot;

shared static this()
{
	if(tempDir() == ".")
		tempDirsRoot = makeTempDirsRoot();
	else
		tempDirsRoot = tempDir();

	removeTempFiles();
}

shared static ~this()
{
	removeTempFiles();
}



string makePrivateTempDir() { return makePrivateTempDir(0); }

string makePrivateTempDir(int n)
{
	enforce(n < 1000,
		"Could not create a temporary directory");

	string dir = tempDirsRoot ~ "caLib3_" ~ to!string(uniform(1000, 9999));

	if(exists(dir))
		return makePrivateTempDir();

	mkdirRecurse(dir);
	return dir;
}



private void removeTempFiles()
{
	if(!exists(tempDirsRoot))
		return;
	
	auto dirs = dirEntries(tempDirsRoot, SpanMode.shallow);
	
	foreach(dirPath ; dirs)
	{
		string dirName = dirPath[tempDirsRoot.length .. dirPath.length];
		if(dirName.length >= 7 && dirName[0 .. 7] == "caLib3_")
			rmdirRecurse(dirPath);
	}
}



private string makeTempDirsRoot() { return null; }