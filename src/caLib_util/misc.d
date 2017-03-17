module caLib_util.misc;

import std.file : exists, isFile;
import std.process : environment;
import std.string : split;
import caLib_util.build : os;



T mod(T)(T m, T n)
{
	T temp = m % n;
	
    if (temp < 0)
    	temp += n;

    return temp;
}



string findInPATH(string fileName)
{
	string filePath = null;

	foreach(path ; environment.get("PATH").split(';'))
	{
		string temp = path ~ "/" ~ fileName;
		if(exists(temp) && isFile(temp))
			filePath = path ~ "/" ~ fileName;
	}

	return filePath; 
}



string withExecutableBinaryExstention(string fileName)
{
	static if(os == "Windows")
	{
		return fileName ~ ".exe";
	}
	else
	{
		return fileName;
	}
}



string withDynamiclyLinkedExstention(string fileName)
{
	static if(os == "Windows")
	{
		return fileName ~ ".dll";
	}
	else static if(os == "Linux")
	{
		return fileName ~ ".so";
	}
	else static if(os == "OSX")
	{
		pragma(msg, "caLib_util.misc :  withDynamiclyLinkedExstention\nSupport for " ~ os ~ "is not implemented");
		return null;
	}
	else
	{
		static assert(0, "Support for " ~ os ~ "is not implemented");
	}
}
