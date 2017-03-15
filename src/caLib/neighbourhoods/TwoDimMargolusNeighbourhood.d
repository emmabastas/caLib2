module caLib.neighbourhoods.TwoDimMargolusNeighbourhood;

import std.meta;



TwoDimMargolusNeighbourhood* create_TwoDimMargolusNeighbourhood()
{
	return new TwoDimMargolusNeighbourhood();
}



struct TwoDimMargolusNeighbourhood
{

private:

	int shiftState = 1;

public:

	static immutable int Dimension = 2;

	int[2][] getNeighboursCoordinates(int x, int y)
	{
		int xOffset = (x & 1) == 0 ? 1 : -1;
		int yOffset = (y & 1) == 0 ? 1 : -1;

		int rx = x + shiftState - 1;
		int ry = x + shiftState - 1;

		return [[rx + xOffset, ry], [rx, ry + yOffset], [rx + yOffset, ry + xOffset]];
	}

	int[2][] getBlockCoordinates(int x, int y)
	{
		int rx = x*2 + shiftState - 1;
		int ry = y*2 + shiftState - 1;

		return [[rx, ry], [rx+1, ry], [rx, ry+1], [rx+1, ry+1]];
	}

	void shift()
	{
		shiftState = 1 - shiftState;
	}
}

version(unittest)
{
	import caLib_abstract.neighbourhood : isShiftingNeighbourhood;
}

unittest
{
	static assert( isShiftingNeighbourhood!(TwoDimMargolusNeighbourhood, 2));
}