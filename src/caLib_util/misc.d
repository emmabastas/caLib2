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

	static if(os == "Windows")
		string[] envPath = environment.get("PATH").split(";");
	else
		string[] envPath = environment.get("PATH").split(":");

	foreach(path ; envPath)
	{
		string temp = path ~ "/" ~ fileName;
		if(exists(temp) && isFile(temp))
			filePath = path ~ "/" ~ fileName;
	}

	return filePath; 
}