module caLib_util.image;

import std.exception : Exception, enforce;
import std.file : thisExePath;
import std.stdio : writeln;
import std.conv : to;
import std.string : split;
import core.stdc.stdlib : exit;
import caLib_util.build : os, arch;

public import derelict.freeimage.freeimage;
public import caLib_util.structs : Color;



shared static this()
{
	DerelictFI.load();

    FreeImage_SetOutputMessage(&FreeImageErrorHandler);
}



class Image
{

private:

	FIBITMAP* fiBitmap;
	
	int width;
	int height;

public:

	this(int width, int height)
	{
		this(width, height, 24);
	}

	this(int width, int height, int bpp)
	in
	{
		assert(width >= 0);
		assert(height >= 0);
		assert(bpp == 24 || bpp == 32);
	}
	body
	{
		this.width = width;
		this.height = height;

		fiBitmap = FreeImage_Allocate(width, height, bpp,
			0x00FF0000, 0x0000FF00, 0x000000FF);

		enforce(fiBitmap != null, "Fatal error. Unknown error occured when"
			~ "createing the internal bitmap");
	}

	this(FIBITMAP* fiBitmap)
	in
	{ assert(fiBitmap != null); }
	body
	{
		width = FreeImage_GetWidth(fiBitmap);
		height = FreeImage_GetHeight(fiBitmap);

		if (FreeImage_GetBPP(fiBitmap) != 32)
		    fiBitmap = FreeImage_ConvertTo32Bits(fiBitmap);

		this.fiBitmap = fiBitmap;
	}

	static Image fromFile(string path)
	{
		FREE_IMAGE_FORMAT format = FIF_UNKNOWN;

		format = FreeImage_GetFileType(cast(const char*) path, 0);

		if(format == FIF_UNKNOWN)
			format = FreeImage_GetFIFFromFilename(cast(const char*) path);

		enforce(format != FIF_UNKNOWN, "Unknown image format for file " ~ path);

		enforce(FreeImage_FIFSupportsReading(format),
			"No suitable decoder for format file " ~ path);

		FIBITMAP* fiBitmap = FreeImage_Load(format, cast(const char*) path, 0);

		enforce(fiBitmap != null, "The image could not be read");

		return new Image(fiBitmap);
	}

	static Image fromColors(Color* colors, int width, int height)
	in
	{ assert(width >= 0 && height >= 0); }
	body
	{
		Image image = new Image(width, height);

		foreach(col ; 0..width)
		{
			foreach(row ; 0..height)
			{
				image.setPixel(col, row, colors[row * width + col]);
			}
		}

		return image;
	}

	static Image fromColorValues(uint* values, int width, int height)
	in
	{ assert(width >= 0 && height >= 0); }
	body
	{
		Image image = new Image(width, height);

		foreach(col ; 0..width)
		{
			foreach(row ; 0..height)
			{
				image.setPixel(col, row, Color(values[row * width + col]));
			}
		}

		return image;
	}

	~this()
	{
		FreeImage_Unload(fiBitmap);
	}

	void saveToFile(string path)
	{
		enforce(path[path.length-1] != '.',
				"Error. Can't save as image. invalid path: \"" ~ path ~ "\"");

		FREE_IMAGE_FORMAT format =
			FreeImage_GetFIFFromFilename(cast(const char*) path);

		if(format == FIF_UNKNOWN)
			format = getFIFFromExstention(path);

		enforce(format != FIF_UNKNOWN, "Error. Can't save as image."
			~ " Unknown image format or invalied path: " ~ "\"" ~ path ~ "\"");

		int err = 
			FreeImage_Save(format, fiBitmap, cast(const char*) path, 0);

		enforce(err == 1, "Error. Could not save image Error code: "
			~ to!string(err));
	}

	int getWidth()
	{
		return width;
	}

	int getHeight()
	{
		return height;
	}

	Color getPixel(int x, int y)
	in 
	{ assert(x >= 0 && y >= 0); }
	body
	{
		RGBQUAD* fiColor = new RGBQUAD();

		uint err = FreeImage_GetPixelColor(fiBitmap, x, height-y-1, fiColor);

		assert(err == 1, "Fatal error. The internal bitmap structure is unable
			to read its pixel. Error code: "
			~ to!string(err));

		return Color(fiColor.rgbRed, fiColor.rgbGreen, fiColor.rgbBlue,
			fiColor.rgbReserved);
	}

	void setPixel(int x, int y, Color newColor)
	in
	{ assert(x >= 0 && y >= 0); }
	body
	{
		RGBQUAD fiColor = RGBQUAD();
		fiColor.rgbRed = newColor.r;
		fiColor.rgbGreen = newColor.g;
		fiColor.rgbBlue = newColor.b;
		fiColor.rgbReserved = newColor.a;

		FreeImage_SetPixelColor(fiBitmap, x, height-y-1, &fiColor);
	}

	void rescale(int newWidth, int newHeight)
	in
	{ assert(newWidth >= 0 && newHeight >= 0); }
	body
	{
		fiBitmap = FreeImage_Rescale(fiBitmap, newWidth, newHeight, FILTER_BOX);

		enforce(fiBitmap != null, "Fatal error. The internal bitmap could not"
			~ "be rescaled.\nThis may be caused by a bit-depth that can't be"
			~ " handeled, or more likely: Not enough memory");

		width = FreeImage_GetWidth(fiBitmap);
		height = FreeImage_GetHeight(fiBitmap);
	}

	FIBITMAP* getFiBitmap()
	{
		return fiBitmap;
	}

	invariant
    {
    	assert(width >= 0);
    	assert(height >= 0);
        assert(fiBitmap != null);
    }
}



private FREE_IMAGE_FORMAT getFIFFromExstention(string path)
{
	string exstention = path.split(".")[path.split.length];
	return
	[
		"png" : FIF_PNG,
	].get(exstention, FIF_UNKNOWN);
}



extern (C) void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const(char)* message) nothrow
{
	try
	{
		writeln("FreeImage error:", message);
	}
	catch(Exception e)
	{
		exit(-99);
	}
}
