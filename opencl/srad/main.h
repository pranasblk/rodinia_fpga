//========================================================================================================================================================================================================200
//	MAIN HEADER
//========================================================================================================================================================================================================200

//====================================================================================================100
//	DEFINE
//====================================================================================================100

#ifdef FP_DOUBLE
#define fp double
#else
#define fp float
#endif

#ifdef RD_WG_SIZE_0_0
        #define NUMBER_THREADS RD_WG_SIZE_0_0
#elif defined(RD_WG_SIZE_0)
        #define NUMBER_THREADS RD_WG_SIZE_0
#elif defined(RD_WG_SIZE)
        #define NUMBER_THREADS RD_WG_SIZE
#else
        #define NUMBER_THREADS 256
#endif

// for all versions
#ifndef RED_UNROLL
	#define RED_UNROLL 8
#endif

// for v5
#define HALO 			2 // this kernel has two stencils; hence, halo size is 2 instead of 1

#ifndef BSIZE
	#ifdef AOCL_BOARD_de5net_a7
		#define BSIZE 4096
	#elif  AOCL_BOARD_p385a_sch_ax115
		#define BSIZE 4096
	#else
		#define BSIZE 256
	#endif
#endif

#ifndef SSIZE
	#ifdef AOCL_BOARD_de5net_a7
		#define SSIZE 4
	#elif  AOCL_BOARD_p385a_sch_ax115
		#define SSIZE 16
	#else
		#define SSIZE 2
	#endif
#endif


//====================================================================================================100
//	End
//====================================================================================================100

//========================================================================================================================================================================================================200
//	End
//========================================================================================================================================================================================================200
