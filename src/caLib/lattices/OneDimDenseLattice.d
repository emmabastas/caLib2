module caLib.lattices.OneDimDenseLattice;

import caLib_abstract.neighbourhood : isNeighbourhood;
import caLib_abstract.util : formatBehaviour;

import caLib_util.misc : mod;
import std.algorithm.searching : canFind;



auto create_OneDimDenseLattice(Ct, Nt)(int width, Nt* neighbourhood)
if(isNeighbourhood!(Nt, 1))
in
{
    assert(width > 0);
    assert(neighbourhood !is null);
}
body
{
    return create_OneDimDenseLattice(width, neighbourhood, 0, 0);
}



auto create_OneDimDenseLattice(Ct, Nt)(int width, Nt* neighbourhood,
    Ct emptyCellState, Ct initialCondition)
if(isNeighbourhood!(Nt, 1))
in
{
    assert(width > 0); 
    assert(neighbourhood !is null);
}
body
{
    return create_OneDimDenseLattice(width, neighbourhood, emptyCellState,
    	(int x) { return initialCondition; });
}



auto create_OneDimDenseLattice(Ct, Nt)(int width, Nt* neighbourhood,
    Ct emptyCellState, Ct delegate(int x) initialCondition)
if(isNeighbourhood!(Nt, 1))
in
{
    assert(width > 0);
    assert(neighbourhood !is null);
}
body
{
    return new OneDimDenseLattice!(Ct, Nt)(width, neighbourhood,
        emptyCellState, initialCondition);
}



struct OneDimDenseLattice(Ct, Nt) if(isNeighbourhood!(Nt, 1))
{

private:

	Nt* neighbourhood;

	int width;

	Ct[] a, b;
	Ct[]* lattice, latticeNextGen;

	Ct emptyCellState;

public:

	alias CellStateType = Ct;
	alias NeighbourhoodType = Nt;
	enum uint Dimension = 1;

	this(int width, Nt* neighbourhood, Ct emptyCellState,
		Ct delegate(int x) initialCondition)
	in
	{
		assert(width > 0);
		assert(neighbourhood !is null);
	}
	body
	{
		this.width = width;

        this.neighbourhood = neighbourhood;

        this.emptyCellState = emptyCellState;

        a.length = width;
        b.length = width;
        lattice = &a;
        latticeNextGen = &b;

        foreach(col; 0 .. width)
        {
            lattice[0][col] = initialCondition(col);
        }
	}



	Ct get(string behaviour)(int x)
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "torus")
        {
            return lattice[0].ptr[mod(x, width)];
        }
        else static if(behaviour[0] == "bounded" 
        	&& behaviour.canFind("assumeInBounds"))
        {
            return lattice[0].ptr[x];
        }
        else static if(behaviour[0] == "bounded")
        {
            if(x >= 0 && x < width)
            {
                return lattice[0].ptr[x];
            }
            else
            {
                return emptyCellState;
            }
        }
        else static if(behaviour[0] == "_test")
        {
            return Ct.init;
        }
        else
        {
            static assert(0, "OneDimDenseLattice get method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    Ct get(int x)
    {
        return get!"bounded"(x);
    }



    void set(string behaviour)(int x, Ct newValue)
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour.canFind("instant")) {
            alias latticeToChange = lattice;
        } else {
            alias latticeToChange = latticeNextGen;
        }

        static if(behaviour[0] == "torus")
        {
            latticeToChange[0].ptr[mod(x, width)] = newValue;
        }
        else static if(behaviour[0] == "bounded"
            && behaviour.canFind("assumeInBounds"))
        {
            latticeToChange[0].ptr[x] = newValue;
        }
        else static if(behaviour[0] == "bounded")
        {
            if(x >= 0 && x < width)
            {
                latticeToChange[0].ptr[x] = newValue;
            }
        }
        else static if(behaviour[0] == "_test")
        {

        }
        else
        {
            static assert(0, "OneDimDenseLattice set method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    void set(int x, Ct newValue)
    {
        set!"bounded"(x, newValue);
    }



    Ct[] getNeighbours(string behaviour)(int x)
    {
        enum string behaviourString = behaviour;
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "torus"
               || behaviour[0] == "bounded")
        {
            Ct[] neighbours;
            foreach(coord ; neighbourhood.getNeighboursCoordinates(x))
            {
                neighbours ~= [get!behaviourString(coord[0])];
            }
            return neighbours;
        }
        else static if(behaviour[0] == "_test")
        {
            return Ct[].init;
        }
        else
        {
            static assert(0, "OneDimDenseLattice getNeighbours method dosen't" 
                ~ "have a \"" ~ behaviour ~ "\" behaviour");
        }
    }



    Ct[] getNeighbours(int x)
    {
        return getNeighbours!"bounded"(x);
    }



    void iterate(string behaviour)(Ct delegate(Ct cellState, Ct[] neighbours,
        int x) rule)
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "all")
        {
            foreach(x; 0 .. width)
            {
                set(x, rule(get(x), getNeighbours(x), x));
            }
        }
        else static if(behaviour[0] == "_test")
        {

        }
        else
        {
            static assert(0, "OneDimDenseLattice iterate method dosen't have a"
                ~ "\"" ~ behaviour ~"\" behaviour");
        }
    }



    void iterate(Ct delegate(Ct cellState, Ct[] neighbours,
        int x) rule)
    {
        iterate!"all"(rule);
    }



    void nextGen(string behaviour)()
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "correct")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;

            foreach(i; 0 .. width)
            {
                latticeNextGen[0].ptr[i] = emptyCellState;
            }
        }
        else static if(behaviour[0] == "toggle")
        {
            lattice[0] = latticeNextGen[0].dup;
        }
        else static if(behaviour[0] == "flipp")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;
        }
        else static if(behaviour[0] == "nothing")
        {}
        else static if(behaviour[0] == "_test")
        {}
        else
        {
            static assert(0, "OneDimDenseLattice nextGen method dosen't have a"
                ~ "\"" ~ behaviour ~"\" behaviour");
        }
    }

    void nextGen()
    {
        nextGen!"correct"();
    }

    int[1] getLatticeBounds()
    out(result)
    {
        assert(result[0] > 0);
    }
    body
    {
        return [width];
    }
}
