module caLib.neighbourhoods.TwoDimVonNeumannNeighbourhood;



TwoDimVonNeumannNeighbourhood* create_TwoDimVonNeumannNeighbourhood()
{
	return new TwoDimVonNeumannNeighbourhood();
}



struct TwoDimVonNeumannNeighbourhood
{

public:

	enum uint Dimension = 2;
	enum uint NeighboursAmount = 4;

	int[2][] getNeighboursCoordinates(int x, int y)
	{
		return [[x, y-1], [x-1, y], [x+1, y], [x, y+1]];

	}
}

version(unittest)
{
	import caLib_abstract.neighbourhood : isStaticNeighbourhood;
}

unittest
{
	static assert( isStaticNeighbourhood!(TwoDimVonNeumannNeighbourhood, 2));
}