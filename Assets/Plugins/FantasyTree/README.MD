MIT License 2020 Prismatic Simulations


Huge thanks to my patrons for making this possible!
If you would like to support and get this / other
tools early / free please check out https://www.patreon.com/cabbibo

Notes:

- Please keep this plugin in Plugins/FantasyTree as that is where the path is set. if you need to change it, its at the very top of Tree.cs
- Once you have decided on a mesh you like, make sure you click 'Save New Mesh' this will save the mesh as a proper asset instead of storing it in the scene information
- It will save every tree mesh you make this way, for ease of use in seperate projects, but keep in mind you can be creating GBs of new assets in minutes ( the power of procedural )!
- currently no way to save teh animation curves for the trunks and branches im sorry! 
- If you aren't seeing trees, it could be because this the animation curves got corrupted...
- To save a new tree set, change the 'Save Name' and then press save.
- its possible to generate wayyy too much stuff so be careful
- you may want to add the tree data to your gitignore if you are making complex trees


Under the hood:

To save all of the procedural information within the mesh itself 
we are using multiple texturecoordinates.

In our case:

uv0 refers to base uv
uv1 refers to centerPosition ( a float3 )
uv2 refers to baseVal , total points and normalized time of creation ( that last one we use the most! )
uv3 refers to offset and row for flowers, and debug for trunk!

Check out the Build Mesh function if you want to dig into these values


There is a bunch of commented-out code throughout the tree.cs file. 
this is all there if you would prefer to do things through DrawProcedural 
and ComputeBuffers! otherwise you shouldn't really have to worry about it :)


Explanation of parameters

Many of the parameters will have a "REDUCER" value. this is the value
that the base value will be multiplied by every iteration level.

for example:

if you had a Length value of 8 and a reducer value of .5,
then your trunk would have a lenght of 8, the first branches
a lenght of 4, the second branches a length of 2, 3rd  1 , 4th .5 , etc. 

if the value is GREATER than one, it will grow. ( 8 -> 16 -> 32 for reducer of 2)


Parameters:


Branching Info:

Points Per Branch: amount of points to make a branch. more points means more resolution, but also less smoothness
Max Number Branches Per Branch: The total possible spawns of branches on a branch. this number will create exponential growth
Branch Chance: chance of each sub branch spawning. If 1, than each branch will create Max Number of Branches Per Branch
Noise Power : Amount noise will effect the growth of the limbs
Noise Size : Size of noise affecting limbs
Min Angle Match : min direction of the match with parent limb. 0 will be perpendicular, 1 is parallel
Max Angle Match : See above
Base Vs Tip Length : Size of branch depending on where they spawn on their parent branch
Length : Length of branch
Length Variation : Variation of length on new branch spawn
Up Desire : Force of limbs to grow upwards
StartBranch Location : Where on branch sub branches start growing
End of Branch Weight : How much branches want to grow on the end of a parent branch


Bark Info:
Width: Thickness of Branch
Width Cutoff: Width which if a branch is smaller than will not get drawn
Num Bark Columns: Number of verts around the circumfrance of the branch
Num Bark Rows: number of Verts along the branch.


Flower Info:
Num Flowers: total number flowers per end branch
Flower Size : Size of flower
Flower Siuze Randomness: Randomness to flower size
Fower Min Direction Match: min direction of flower ( 0 = perp , 1 = parallel)
Fower Max Direction Match: Max direction of flower ( 0 = perp , 1 = parallel)
Offset Size : How much flower is offset from branch


Limits:
Max Iteration level: how many levels down to go
Max Branches: Total possible branches
Max Points : Total possible points in branches

Trunk Curve: Shape of trunk
Branch Curve: Shape of every other branch










