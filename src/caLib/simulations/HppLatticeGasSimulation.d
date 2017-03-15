module caLib.simulations.HppLatticeGasSimulation;

import std.algorithm.searching : countUntil;
import caLib.lattices.TwoDimDenseLattice;
import caLib.renderers.TwoDimBasicRenderer;
import caLib_util.structs : Simulation, create_Simulation;
import caLib_util.structs : Color;

public import caLib_util.graphics : Window;

import std.stdio;



auto create_HppLatticeGasSimulation(int width, int height,
	ubyte delegate(int x, int y) initialCondition, Window window)
{
	auto lattice = create_TwoDimDenseLattice(width, height,
		new DummyNeighbourhood(), ubyte(0), initialCondition);

	auto rule = new HppLatticeGasRule(lattice);

	auto renderer = create_TwoDimBasicRenderer(lattice, new HppLatticeGasPalette(), window);

	return create_Simulation(lattice, rule, renderer);
}



struct HppLatticeGasRule
{

private:

	alias Lt = TwoDimDenseLattice!(ubyte, DummyNeighbourhood);

	Lt* lattice;
	int latticeWidth;
	int latticeHeight;

	static immutable ubyte[] ruleSet =
	(){
		ubyte[] ruleSet;

		ruleSet.length = 16;
		foreach(ubyte i; 0 .. 16)
		{
			ruleSet[i] = i;

			if(i == 3)
				ruleSet[i] = 12;
			if(i == 12)
				ruleSet[i] = 3;
		}

		ruleSet.length = 32;
		foreach(ubyte i; 16 .. 32)
		{
			ruleSet[i] =
				(i << 1 & 2) +
				(i >> 1 & 1) +
				(i << 1 & 8) +
				(i >> 1 & 4) +
				16;
		}

		return ruleSet;
	}();

public:

	this(Lt* lattice)
	{
		this.lattice = lattice;
		this.latticeWidth = lattice.getLatticeBounds[0];
		this.latticeHeight = lattice.getLatticeBounds[1];
	}

	void applyRule()
	{
		foreach(y; 0 .. latticeHeight)
		{
			foreach(x; 0 .. latticeWidth)
			{
				ubyte afterTransportation =
					(lattice.get!"torus"(x+1, y) & 1) +
					(lattice.get!"torus"(x-1, y) & 2) +
					(lattice.get!"torus"(x, y+1) & 4) +
					(lattice.get!"torus"(x, y-1) & 8) +
					(lattice.get!"bounded-assumeInBounds"(x,y) & 16);

				ubyte afterCollision = ruleSet[afterTransportation];

				lattice.set!"bounded-assumeInBounds"(x, y, afterCollision);
			}
		}
		lattice.nextGen();
	}

	void applyRuleReverse() {}
}



private struct HppLatticeGasPalette
{
	alias CellStateType = ubyte;
	alias DisplayValueType = Color;

	Color getDisplayValue(string behaviour)(ubyte cellState)
	{
		uint intensity = cast(ubyte)(
			(cellState >> 0 & 1) + (cellState >> 1 & 1) +
		    (cellState >> 2 & 1) + (cellState >> 3 & 1)) * 255/4;
		
		return Color(intensity + (intensity << 8) + (intensity << 16));
	}

	Color getDisplayValue(ubyte cellState)
	{
		return getDisplayValue!""(cellState);
	}
}



private struct DummyNeighbourhood
{
	static immutable int Dimension = 2;
	int[2][] getNeighboursCoordinates(int x, int y) { return []; }
}



version(unittest)
{
	import caLib_abstract.neighbourhood : isNeighbourhood;
	import caLib_abstract.rule : isReversibleRule;
}



unittest
{
	static assert(isNeighbourhood!(DummyNeighbourhood, 2));
	static assert(isReversibleRule!(HppLatticeGasRule));
}