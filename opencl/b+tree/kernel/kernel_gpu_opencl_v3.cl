#include "../problem_size.h"

// #ifdef __cplusplus
// extern "C" {
// #endif

//========================================================================================================================================================================================================200
//	DEFINE/INCLUDE
//========================================================================================================================================================================================================200

//======================================================================================================================================================150
//	DEFINE
//======================================================================================================================================================150

// Doesn't seem to be used
#if 0
// double precision support (switch between as needed for NVIDIA/AMD)
#ifdef AMDAPP
#pragma OPENCL EXTENSION cl_amd_fp64 : enable
#else
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#endif
#endif
// clBuildProgram compiler cannot link this file for some reason, so had to redefine constants and structures below
// #include ../common.h						// (in directory specified to compiler)			main function header

//======================================================================================================================================================150
//	DEFINE (had to bring from ../common.h here because feature of including headers in clBuildProgram does not work for some reason)
//======================================================================================================================================================150

// Doesn't seem to be used
// change to double if double precision needed
//#define fp float

//#define DEFAULT_ORDER 256

//======================================================================================================================================================150
//	STRUCTURES (had to bring from ../common.h here because feature of including headers in clBuildProgram does not work for some reason)
//======================================================================================================================================================150

// Type representing the record to which a given key refers. In a real B+ tree system, the record would hold data (in a database) or a file (in an operating system) or some other information.
// Users can rewrite this part of the code to change the type and content of the value field.
typedef struct record {
  int value;
} record;

// ???
typedef struct knode {
  int location;
  int indices [DEFAULT_ORDER + 1];
  int  keys [DEFAULT_ORDER + 1];
  bool is_leaf;
  int num_keys;
} knode; 

//========================================================================================================================================================================================================200
//	findK function
//========================================================================================================================================================================================================200

__kernel void 
findK(long height,
      __global knode * restrict knodesD,
      long knodes_elem,
      __global record * restrict recordsD,
      __global long * restrict currKnodeD,
      __global long * restrict offsetD,
      __global int * restrict keysD, 
      __global record * restrict ansD,
      int count,
      int order) {
  // Similar to the OpenMP version
  int count_even = count & (~1);
  // processtree levels  
  for(int i = 0; i < height; i++){  
#pragma unroll 2
    for(int bid = 0; bid < count_even; bid++){
      for (int thid = 0; thid < order; thid++) {
        // if value is between the two keys
        if((knodesD[currKnodeD[bid]].keys[thid]) <= keysD[bid] &&
           (knodesD[currKnodeD[bid]].keys[thid+1] > keysD[bid])){
          // this conditional statement is inserted to avoid crush due to but in original code
          // "offset[bid]" calculated below that addresses knodes[] in the next iteration goes outside of its bounds cause segmentation fault
          // more specifically, values saved into knodes->indices in the main function are out of bounds of knodes that they address
          if(knodesD[offsetD[bid]].indices[thid] < knodes_elem){
            offsetD[bid] = knodesD[offsetD[bid]].indices[thid];
            break;
          }
        }
      }
      currKnodeD[bid] = offsetD[bid];
    }

    // remaining iteration
    int bid = count_even;
    if (bid < count) {
      // processtree levels
      for(int i = 0; i < height; i++){
        for (int thid = 0; thid < order; thid++) {
          // if value is between the two keys
          if((knodesD[currKnodeD[bid]].keys[thid]) <= keysD[bid] &&
             (knodesD[currKnodeD[bid]].keys[thid+1] > keysD[bid])){
            // this conditional statement is inserted to avoid crush due to but in original code
            // "offset[bid]" calculated below that addresses knodes[] in the next iteration goes outside of its bounds cause segmentation fault
            // more specifically, values saved into knodes->indices in the main function are out of bounds of knodes that they address
            if(knodesD[offsetD[bid]].indices[thid] < knodes_elem){
              offsetD[bid] = knodesD[offsetD[bid]].indices[thid];
              break;
            }
          }
        }
        currKnodeD[bid] = offsetD[bid];
      }
    }
  }


  //At this point, we have a candidate leaf node which may contain
  //the target record.  Check each key to hopefully find the
  //record
  for(int bid = 0; bid < count; bid++){  
    for (int thid = 0; thid < order; thid++) {
      if(knodesD[currKnodeD[bid]].keys[thid] == keysD[bid]){
        ansD[bid].value = recordsD[knodesD[currKnodeD[bid]].indices[thid]].value;
        break;
      }
    }
  }  
}

//========================================================================================================================================================================================================200
//	End
//========================================================================================================================================================================================================200

// #ifdef __cplusplus
// }
// #endif
