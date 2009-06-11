#############################################################################
##
##  Posets.gi                      Conley package            Mohamed Barakat
##
##  Copyright 2009, Mohamed Barakat, Universität des Saarlandes
##
##  Implementations of procedures for posets.
##
#############################################################################

####################################
#
# representations:
#
####################################

# a new representation for the GAP-category IsPoset:

##  <#GAPDoc Label="IsPosetRep">
##  <ManSection>
##    <Filt Type="Representation" Arg="P" Name="IsPosetRep"/>
##    <Returns>true or false</Returns>
##    <Description>
##      The representation of posets. <P/>
##      (It is a representation of the &GAP; category <Ref Filt="IsPoset"/>.)
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPosetRep",
        IsPoset,
        [ "set", "defining_relations" ] );

####################################
#
# families and types:
#
####################################

# a new family:
BindGlobal( "TheFamilyOfPosets",
        NewFamily( "TheFamilyOfPosets" ) );

# a new type:
BindGlobal( "TheTypePoset",
        NewType( TheFamilyOfPosets,
                IsPosetRep ) );

####################################
#
# methods for attributes:
#
####################################

##
InstallMethod( Length,
        "for posets",
        [ IsPoset ],
        
  function( P )
    
    return Length( UnderlyingSet( P ) );
    
end );

####################################
#
# methods for operations:
#
####################################

##  <#GAPDoc Label="UnderlyingSet">
##  <ManSection>
##    <Oper Arg="P" Name="UnderlyingSet" Label="for posets"/>
##    <Returns>a list</Returns>
##    <Description>
##      The set underlying the poset <A>P</A>.
##      <Example><![CDATA[
##  gap> Poset( [1,2,3], [[3,2],[2,1]] );
##  <A poset on 3 points>
##  gap> UnderlyingSet( last );
##  [ 1, 2, 3 ]
##  ]]></Example>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( UnderlyingSet,
        "for posets",
        [ IsPoset ],
        
  function( P )
    
    return P!.set;
    
end );

##  <#GAPDoc Label="PartialOrder">
##  <ManSection>
##    <Oper Arg="rel" Name="PartialOrder"/>
##    <Returns>a list</Returns>
##    <Description>
##      The partial order > generated by the list <A>rel</A> of relations. <A>rel</A> consists of pairs <M>(p,q)</M>
##      which mean that <M>p>q</M>.
##      <Example><![CDATA[
##  gap> P := Poset( [1,2,3], [[3,2],[2,1]] );
##  <A poset on 3 points>
##  gap> PartialOrder( P );
##  [ [ 2, 1 ], [ 3, 1 ], [ 3, 2 ] ]
##  gap> P := Poset( [1,2,3], [0,1,Float(3/2)] );
##  <A poset on 3 points>
##  gap> PartialOrder( P );
##  [ [ 2, 1 ], [ 3, 1 ], [ 3, 2 ] ]
##  ]]></Example>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( PartialOrder,
        "for posets",
        [ IsPoset ],
        
  function( P )
    local set, rel, n, REL, i, j, REL2, REL1, a, ord;
    
    if IsBound(P!.PartialOrder) then
        return P!.PartialOrder;
    fi;
    
    set := UnderlyingSet( P );
    rel := P!.defining_relations;
    
    n := Length( P );
    
    ## ones on the diagonal
    REL := HomalgInitialIdentityMatrix( n, n, CONLEY.ZZ );
    
    for i in [ 1 .. n ] do
        for j in [ 1 .. n ] do
            if i <> j and Position( rel, [ set[i], set[j] ] ) <> fail then
                SetEntryOfHomalgMatrix( REL, i, j, 1 );
            fi;
        od;
    od;
    
    ## ones on the diagonal
    REL1 := HomalgInitialIdentityMatrix( n, n, CONLEY.ZZ );
    
    REL2 := REL^2;
    
    for i in [ 1 .. n ] do
        for j in [ 1 .. n ] do
            if i <> j then
                a := GetEntryOfHomalgMatrix( REL2, i, j );
                SetEntryOfHomalgMatrix( REL1, i, j, SignInt( a ) );
            fi;
        od;
    od;
    
    while REL1 <> REL do
        REL := REL1;
        
        ## ones on the diagonal
        REL1 := HomalgInitialIdentityMatrix( n, n, CONLEY.ZZ );
        
        REL2 := REL^2;
        
        for i in [ 1 .. n ] do
            for j in [ 1 .. n ] do
                if i <> j then
                    a := GetEntryOfHomalgMatrix( REL2, i, j );
                    SetEntryOfHomalgMatrix( REL1, i, j, SignInt( a ) );
                fi;
            od;
        od;
    od;
    
    ord := [ ];
    
    for i in [ 1 .. n ] do
        for j in [ 1 .. n ] do
            if i <> j and GetEntryOfHomalgMatrix( REL, i, j ) = 1 then
                Add( ord, [ set[i], set[j] ] );
            fi;
        od;
    od;
    
    P!.PartialOrder := Set( ord );
    
    return P!.PartialOrder;
    
end );

####################################
#
# constructor functions and methods:
#
####################################

##  <#GAPDoc Label="Poset">
##  <ManSection>
##    <Oper Arg="P, rel" Name="Poset" Label="constructor for posets"/>
##    <Returns>a poset</Returns>
##    <Description>
##      A poset (partially ordered set) with underlying set <A>P</A> and relation > given by the set <A>rel</A>.
##      <Example><![CDATA[
##  gap> Poset( [1,2,3], [[3,2],[2,1]] );
##  <A poset on 3 points>
##  gap> Poset( [1,2,3], [0,1,Float(3/2)] );
##  <A poset on 3 points>
##  ]]></Example>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( Poset,
        "for sets",
        [ IsList, IsList ],
        
  function( _P, _rel )
    local P, rel, points, n, i, j, poset;
    
    if Length( _P ) = 0 then
        Error( "The first argument is an empty set\n" );
    fi;
    
    if ForAll( _rel, IsList ) and Set( List( _rel, Length ) ) = [ 2 ] then
        
        ## defining relations are given as a list
        
        if not IsSet( _P ) then
            P := Set( _P );
        else
            P := _P;
        fi;
        
        if not IsSet( _rel ) then
            rel := Set( _rel );
        else
            rel := _rel;
        fi;
        
        points := Set( Flat( rel ) );
        
        if not IsSubsetSet( P, points ) then
            Error( Difference( P, points ), " are not in points of the first argument\n");
        fi;
        
        poset := rec( set := P,
                      defining_relations := rel );
        
    elif Length( _P ) = Length( _rel ) then
        
        ## a potential is given as a list
        
        P := _P;	## don't make a set out of it, since the correspondence to the potential values might get distroy
        
        n := Length( P );
        
        rel := [ ];
        
        for i in [ 1 .. n ] do
            for j in [ i + 1 .. n ] do
                if _rel[i] > _rel[j] then
                    Add( rel, [ P[i], P[j] ] );
                elif _rel[i] < _rel[j] then
                    Add( rel, [ P[j], P[i] ] );
                fi;
            od;
        od;
        
        rel := Set( rel );
        
        poset := rec( set := P,
                      defining_relations := rel,
                      PartialOrder := rel );
        
    fi;
    
    ObjectifyWithAttributes(
            poset, TheTypePoset
            );
    
    return poset;
    
end );

####################################
#
# View, Print, and Display methods:
#
####################################

##
InstallMethod( ViewObj,
        "for posets",
        [ IsPoset ],
        
  function( P )
    
    Print( "<A poset on ", Length( P ), " points>" );
    
end );

##
InstallMethod( Display,
        "for posets",
        [ IsPoset ],
        
  function( P )
    
    Print( "A poset with underlying set:\n", UnderlyingSet( P ), "\n\nand partial order:\n", PartialOrder( P ), "\n" );
    
end );

