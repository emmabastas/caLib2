module caLib.simulations.ElementaryCA;

import caLib.neighbourhoods.OneDimBasicNeighbourhood;
import caLib.lattices.OneDimDenseLattice;
import caLib.rules.BinaryRule;
import caLib.palettes.ColorListPalette;
import caLib.renderers.OneDimBasicRenderer;

public import caLib_util.graphics : Window;
import caLib_util.structs : Simulation, create_Simulation, Color;
import std.bigint;
import std.conv : to;



auto create_ElementaryCA(int width, ubyte ruleNumber,
	ubyte delegate(int x) initialCondition, Window window)
in
{
	assert(width > 0);
}
body
{
	ruleNumber = wolframRuleNumberToRuleNumber(ruleNumber);

	auto neighbourhood = create_OneDimBasicNeighbourhood;
	auto lattice = create_OneDimDenseLattice(width, neighbourhood, ubyte(0),
		initialCondition);

	auto rule = create_BinaryRule(lattice, BigInt(to!string(ruleNumber)));

	auto palette = create_ColorListPalette([ubyte(0):Color(0), ubyte(1):Color(uint.max)], Color(255,0,0));
	auto renderer = create_OneDimBasicRenderer(lattice, palette, window);

	return create_Simulation(lattice, rule, renderer);
}



ubyte wolframRuleNumberToRuleNumber(ubyte ruleNumber)
{
	ruleNumber =
		((ruleNumber & 1) << 0) +
		((ruleNumber & 2) << 3) +
		((ruleNumber & 4) << 0) +
		((ruleNumber & 8) << 3) +
		((ruleNumber & 16) >> 3) +
		((ruleNumber & 32) >> 0) +
		((ruleNumber & 64) >> 3) +
		((ruleNumber & 128) >> 0);

	ruleNumber =
		((ruleNumber & 1) << 0) +
		((ruleNumber & 2) << 0) +
		((ruleNumber & 4) << 2) +
		((ruleNumber & 8) << 2) +
		((ruleNumber & 16) >> 2) +
		((ruleNumber & 32) >> 2) +
		((ruleNumber & 64) << 0) +
		((ruleNumber & 128) << 0);

	return ruleNumber;
}