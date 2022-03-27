//#pragma OPENCL EXTENSION cl_khr_fp64 : enable
typedef unsigned long uint64_t;
typedef unsigned long uint32_t;
typedef long int64_t;
typedef union { uint64_t u64; double d; } U64double;

double computeValue(double seed) {
	uint64_t u10;
	uint64_t u11;
	uint64_t u12;
	uint64_t u13;
    u10 = (((uint64_t)0xa0d27757 << 32) + (uint64_t)0x0a345b8c);
    u11 = (((uint64_t)0x764a296c << 32) + (uint64_t)0x5d4aa64f);
    u12 = (((uint64_t)0x51220704 << 32) + (uint64_t)0x070adeaa);
    u13 = (((uint64_t)0x2a2717b5 << 32) + (uint64_t)0xa7b7b927);
    uint32_t r3 = 0x11090601;  /* 64-k[i] as four 8 bit constants. */

    U64double u;
    uint32_t m = 1u << (r3&255);
    r3 >>= 8;
    u.d = seed = seed * 3.14159265358979323846 + 2.7182818284590452354;
    if (u.u64 < m) u.u64 += m;  /* Ensure k[i] MSB of u[i] are non-zero. */
    u10 = u.u64;
    U64double uy1;
    uint32_t my1 = 1u << (r3&255);
    r3 >>= 8;
    uy1.d = seed = seed * 3.14159265358979323846 + 2.7182818284590452354;
    if (uy1.u64 < my1) uy1.u64 += my1;  /* Ensure k[i] MSB of u[i] are non-zero. */
    u11 = uy1.u64;
    U64double uy2;
    uint32_t my2 = 1u << (r3&255);
    r3 >>= 8;
    uy2.d = seed = seed * 3.14159265358979323846 + 2.7182818284590452354;
    if (uy2.u64 < my1) uy2.u64 += my2;  /* Ensure k[i] MSB of u[i] are non-zero. */
    u12 = uy2.u64;
    U64double uy3;
    uint32_t my3 = 1u << (r3&255);
    r3 >>= 8;
    uy3.d = seed = seed * 3.14159265358979323846 + 2.7182818284590452354;
    if (uy3.u64 < my1) uy3.u64 += my2;  /* Ensure k[i] MSB of u[i] are non-zero. */
    u13 = uy3.u64;
    for (int i = 0; i < 10; i++) {
      // rs, z, r, i, k, q, s
      uint64_t z, r = 0;
      z = u10;
      z = (((z<<31)^z) >> (63-18)) ^ ((z&((uint64_t)(int64_t)-1 << (64-63)))<<18);
      r ^= z; 
      u10 = z;
      z = u11;
      z = (((z<<19)^z) >> (58-28)) ^ ((z&((uint64_t)(int64_t)-1 << (64-58)))<<28);
      r ^= z;
      u11 = z;
      z = u12;
      z = (((z<<24)^z) >> (55-7)) ^ ((z&((uint64_t)(int64_t)-1 << (64-55)))<<7);
      r ^= z;
      u12 = z;
      z = u13;
      z = (((z<<21)^z) >> (47-8)) ^ ((z&((uint64_t)(int64_t)-1 << (64-47)))<<8);
      r ^= z;
      u13 = z;
    }
	U64double ur;
    double df;
    uint64_t z, r = 0;
    z = u10;
    z = (((z<<31)^z) >> (63-18)) ^ ((z&((uint64_t)(int64_t)-1 << (64-63)))<<18);
    r ^= z; 
    u10 = z;
    z = u11;
    z = (((z<<19)^z) >> (58-28)) ^ ((z&((uint64_t)(int64_t)-1 << (64-58)))<<28);
    r ^= z;
    u11 = z;
    z = u12;
    z = (((z<<24)^z) >> (55-7)) ^ ((z&((uint64_t)(int64_t)-1 << (64-55)))<<7);
    r ^= z;
    u12 = z;
    z = u13;
    z = (((z<<21)^z) >> (47-8)) ^ ((z&((uint64_t)(int64_t)-1 << (64-47)))<<8);
    r ^= z;
    u13 = z;
    ur.u64 = (r & (((uint64_t)0x000fffff << 32) + (uint64_t)0xffffffff) | (((uint64_t)0x3ff00000 << 32) + (uint64_t)0x00000000));
    df = ur.d - 1.0;
   	return df;
}

__kernel void seedKernel(__global const int *args, __global long *output) {
    // pass range: 0-419096
    int pass = args[0];

    // example 10000000
    int start = args[6];

    // gid range: 0-2147483645
    int gid = get_global_id(0); // this returns size_t which is an unsigned int

    ulong zeed = ((ulong)pass*2147483646) + ((ulong)start*10000000) + (ulong)gid;

    printf("%lu\n", zeed);

    //if (zeed >= 100002147483645) printf("gid %d.. pass %d.. start %d.. zeed %ld\n", gid, pass, start, zeed);
    //if (gid < 10) printf("gid %d\n", gid);
    //if (gid > 2147483640) printf("gid %d\n", gid);
    //uint64_t zeed = ((long)(pass*2147483646)) + ((long)gid) + ((long)start*10000000); // 100000000000000

	double first_seed = (double) (zeed);
	double roll1 = computeValue(first_seed);
	int roll1i = (int)(roll1*1000000);
    if (roll1i == args[1]) {
        double roll2 = computeValue(roll1);
        int roll2i = (int)(roll2*1000000);
        if (roll2i == args[2]) {
            double roll3 = computeValue(roll2);
            int roll3i = (int)(roll3*1000000);
            if (roll3i == args[3]) {
                double roll4 = computeValue(roll3);
                int roll4i = (int)(roll4*1000000);
                if (roll4i == args[4]) {
                    double roll5 = computeValue(roll4);
                    int roll5i = (int)(roll5*1000000);
                    if (roll5i == args[5]) {
                        output[0] = 777;
                        output[1] = zeed;
                    }
                }
            }
        }
    }
}