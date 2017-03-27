module caLib.neighbourhoods.OneDimBasicNeighbourhood;



OneDimBasicNeighbourhood* create_OneDimBasicNeighbourhood()
{
	return new OneDimBasicNeighbourhood();
}



struct OneDimBasicNeighbourhood
{

public:

	enum uint Dimension = 1;
	enum uint NeighboursAmount = 2;

	int[1][] getNeighboursCoordinates(int x)
	{
		return [[x-1], [x+1]];

	}
}

version(unittest)
{
	import caLib_abstract.neighbourhood : isStaticNeighbourhood;
}

unittest
{
	static assert( isStaticNeighbourhood!(OneDimBasicNeighbourhood, 1));
}