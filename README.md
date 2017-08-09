# LakestoneCore
Set of core abstraction for building cross-platform swift codebases. Cross-compiled with Apple's Swift and RemObject's Silver for Java

### How to update for geobingan

whenever the lakestonecore is updated, it needs to be rebuilt (clean first) and added to the kit

pressing build will activate the script of building for the simulator;

pressing archive will activate the script of building for the device

the script automatically copies .framework files into ../GeoBingAnKit/Frameworks/{Debug,Release}

but if the project is in another folder those have to be copied(replaced) manually

bulding the geobingankit will cause the framework to be copied to 'Active' automatically
