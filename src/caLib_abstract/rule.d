/**
* This module defines the notion of a $(RULE). A $(RULE) is the part of
* a $(I cellular automaton) responsible for changing the $(I ca)'s $(I cells) state.
* Each generation the $(RULE) is applied to the $(I cellular automaton) in order to
* get it's $(I cells) new state.
*
* It provides templates for testing whether a given object is a $(RULE), and
* what kind of $(RULE) it is.
*
* $(CALIB_ABSTRACT_DESC)
*/

module caLib_abstract.rule;

/**
* Tests if something is a $(B Rule), defined as having a primitive `applyRule`
*
* returns `true` if `T` is a $(B Rule). A $(B Rule) is the most
* basic form of a $(CU rule). It must define the primitive
* `void applyRule()`.
*
* params: T = the type to be tested
*
* returns: true if T is a $(B Rule), false if not
*/
enum isRule(T) =
    is(typeof(T.init.applyRule()) : void);

///
unittest
{
    struct A { void applyRule() {} }
    struct B { int applyRule(int b) { return int.init; } }
    
    static assert( isRule!A );
    static assert(!isRule!B );
    static assert(!isRule!string );
}



/// Example of a $(B Rule)
struct Rule
{
    void applyRule() {}
}

///
unittest
{
    assert(isRule!Rule);
}



/**
* Tests if something is a $(B ReversibleRule), defined as being a $(B Rule) with
* the additional primitive `applyRuleReverse` 
*
* returns `true` if `T` is a $(B ReversibleRule). A $(B ReversibleRule) can "reverse"
* the state of a $(I ca) to its previours state. It must define the primitive
* `void applyRuleReverse()`, in addition to the primitives defined in $(B Rule)
*
* params: T = the type to be tested
*
* returns: true if T is a $(B ReversibleRule), false if not
*/
enum isReversibleRule(T) =
    isRule!T &&
    is(typeof(T.init.applyRuleReverse()) : void);

///
unittest
{
    struct A
    {
        void applyRule() {}
        void applyRuleReverse() {}
    }
    
    static assert( isRule!A );
    static assert(!isRule!string );
}



/// Example of a $(B ReversibleRule)
struct ReversibleRule
{
    void applyRule() {}
    void applyRuleReverse() {}
}

///
unittest
{
    assert( isRule!ReversibleRule);
    assert( isReversibleRule!ReversibleRule);
    assert(!isReversibleRule!Rule);
}