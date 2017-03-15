/**
* Contains commonly used structs
*/

module caLib_util.structs;

import caLib_abstract.lattice : isLattice;
import caLib_abstract.renderer : isRenderer;
import caLib_abstract.rule : isRule;



///
struct Rect
{
	int x;
	int y;
	int w;
	int h;
}



auto create_Simulation(Lt, Rt, REt)(Lt* lattice, Rt* rule, REt* renderer)
{
	return Simulation!(Lt, Rt, REt)(lattice, rule, renderer);
}

struct Simulation(Lt, Rt, REt)
{
	alias LatticeType = Lt;
	alias RuleType = Rt;
	alias RendererType = REt;

	Lt* lattice;
	Rt* rule;
	REt* renderer;

	this(Lt* lattice, Rt* rule, REt* renderer)
	{
		this.lattice = lattice;
		this.rule = rule;
		this.renderer = renderer;
	}
}



/*
* A struct representing a color.
* Note that this color struct can replace all representations
* of color using uint in the argb8888 format
*/
struct Color
{
	uint value=0;
	alias value this;

	this(ubyte r, ubyte g, ubyte b)
	{
		this(r, g, b, 255);
	}

	this(ubyte r, ubyte g, ubyte b, ubyte a)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	this(uint value)
	{
		this.value = value;
	}

	@property ubyte r() { return (value & 0x00FF0000) >> 16; }
	@property void r(ubyte newR) { value = (value & 0xFF00FFFF) + (newR << 16); }

	@property ubyte g() { return (value & 0x0000FF00) >> 8; }
	@property void g(ubyte newG) { value = (value & 0xFFFF00FF) + (newG << 8); }

	@property ubyte b() { return (value & 0x000000FF) >> 0; }
	@property void b(ubyte newB) { value = (value & 0xFFFFFF00) + (newB << 0); }

	@property ubyte a() { return (value & 0xFF000000) >> 24; }
	@property void a(ubyte newA) { value = (value & 0x00FFFFFF) + (newA << 24); }
}