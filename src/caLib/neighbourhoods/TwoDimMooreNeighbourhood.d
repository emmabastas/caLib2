module caLib.neighbourhoods.TwoDimMooreNeighbourhood;



TwoDimMooreNeighbourhood* create_TwoDimMooreNeighbourhood()
{
	return new TwoDimMooreNeighbourhood();
}



struct TwoDimMooreNeighbourhood
{

private:

public:

	enum uint Dimension = 2;
	enum uint NeighboursAmount = 8;

	int[2][] getNeighboursCoordinates(int x, int y)
	{
		return [[x-1, y-1], [x, y-1], [x+1, y-1],
				[x-1, y], [x+1, y],
				[x-1, y+1], [x, y+1], [x+1, y+1]];

	}
}

version(unittest)
{
	import caLib_abstract.neighbourhood : isStaticNeighbourhood;
}

unittest
{
	static assert( isStaticNeighbourhood!(TwoDimMooreNeighbourhood, 2));
}