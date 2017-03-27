module caLib_util.video;

import std.process : execute, executeShell;
import std.file : mkdirRecurse, rmdir, remove, exists, write, rename, getcwd, thisExePath;
import std.path : buildPath;
import std.exception : enforce;
import std.conv : to;
import std.string : split;
import caLib_util.image : Image;
import caLib_util.misc : findInPATH;
import caLib_util.build : arch, os;
import caLib_util.tempdir : makePrivateTempDir;

import std.stdio : writeln;
import std.random : uniform;



class Video
{

private:

	string creationDir;
	uint nVideos;
	uint nFrames;

	string path;
	uint framerate;

	uint width;
	uint height;

public:

	this(string path, uint framerate)
	{
		this.path = path;

		creationDir = makePrivateTempDir();
		nVideos = 0;
		nFrames = 0;

		this.framerate = framerate;

		width = -1;
		height = -1;
	}

	void addFrame(Image frame)
	{
		if(width == -1 && height == -1)
		{
			width = frame.getWidth();
			height = frame.getHeight();
		}

		try
		{
			frame.saveToFile(creationDir ~ "/" ~ to!string(nFrames) ~ ".png");
			nFrames ++;

			if(nFrames == 10)
				mergeFrames();
		}
		catch(Exception e)
		{
			writeln(e.msg);
			addFrame(frame);
		}
	}

	void saveToFile()
	{
		mergeFrames();
		mergeVideos();
		rename(creationDir ~ "/0.mp4", getcwd() ~ "/" ~ path);
	}

private:

	void mergeFrames()
	{
		auto ret = execute([
			encoderPath,
			"-r", to!string(framerate),
			"-f", "image2",
			"-s", to!string(width) ~ "x" ~ to!string(height),
			"-i", creationDir ~ "/%d.png",
			"-vcodec", "libx264", "-crf", "25", "-pix_fmt", "yuv420p",
			creationDir ~ "/" ~ to!string(nVideos) ~ ".mp4",
		]);
		
		enforce(ret.status == 0, "An error occured when creating video");

		nFrames = 0;
		nVideos ++;

		if(nVideos == 2)
			mergeVideos();
	}

	void mergeVideos()
	{
		string buffer = "";
		foreach(i; 0 .. nVideos)
		{
			buffer = buffer ~ "\nfile " ~  to!string(i) ~ ".mp4";
		}
		write(creationDir ~ "/files.txt", buffer);

		auto ret = execute([
			encoderPath,
			"-f", "concat", "-safe", "0",
			"-i", creationDir ~ "/files.txt",
			"-c", "copy",
			creationDir ~ "/a.mp4",
		]);

		enforce(ret.status == 0, "An error occured when creating video");

		foreach(i; 0 .. nVideos)
		{
			remove(creationDir ~ "/" ~ to!string(i) ~ ".mp4");
		}

		rename(creationDir ~ "/a.mp4",
			creationDir ~ "/0.mp4");

		nVideos = 1;
	}
}



private string decoderPath = null;
private string encoderPath = null;

static this()
{
	enum decoderName = [
		"Windows" : "ffmpeg.exe",
	].get(os, null);

	enum encoderName = [
		"Windows" : "ffmpeg.exe",
	].get(os, null);

	static assert(decoderName != null && encoderName != null,
        "can't compile video.d becuase codec usage is not yet"
        ~ " implemented for " ~ os);

	if(exists(buildPath(thisExePath(), decoderName)))
		decoderPath = buildPath(thisExePath(), decoderName);
	else if(exists(buildPath(getcwd(), decoderName)))
		decoderPath = buildPath(getcwd(), decoderName);
	else
		decoderPath = findInPATH(decoderName);

	if(exists(buildPath(thisExePath(), encoderName)))
		encoderPath = buildPath(thisExePath(), encoderName);
	else if(exists(buildPath(getcwd(), encoderName)))
		encoderPath = buildPath(getcwd(), encoderName);
	else
		encoderPath = findInPATH(decoderName);

	enforce(decoderPath != null && encoderPath != null,
		encoderName ~ " and/or " ~ decoderName ~ ", wich is "
		~ "essential for creating video could not be found on the PATH");
}



