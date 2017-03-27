module caLib_util.initialConditions;

import std.stdio : writeln;
import core.stdc.stdlib : exit;
import std.exception : Exception;
import caLib_util.image : Image, Color;

struct InitialConditionFromImage(CellStateType = Color)
{

private:

	alias Ct = CellStateType;

	Image image;

	Color[Color] corectionLUT;

public:

	this(string imagePath, int latticeWidth, int latticeHeight)
	{
		this(imagePath, latticeHeight, latticeHeight, null);
	}

	this(string imagePath, int latticeWidth, int latticeHeight, Color[Color] corectionLUT)
	in
	{ assert(latticeWidth >= 0 && latticeHeight >= 0); }
	body
	{
		this.corectionLUT = corectionLUT;

		try
		{
			image = Image.fromFile(imagePath);
			image.rescale(latticeWidth, latticeHeight);
		}
		catch(Exception e)
		{
			writeln("An error occured while reading image: " ~ imagePath);
			writeln("Error message: ", e.msg,);
			writeln("A empty image will be used as the initialCondition instead");

			image = new Image(latticeWidth, latticeWidth);
		}
	}

	Ct initialCondition(int x, int y)
	{
		if(corectionLUT == null)
			return cast(Ct) image.getPixel(x, y);
		else
			return cast(Ct) corectionLUT.get(image.getPixel(x, y), image.getPixel(x, y));
	}
}