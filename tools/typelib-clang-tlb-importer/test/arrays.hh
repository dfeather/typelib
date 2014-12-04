#ifndef TEST_HEADER_DATA_ARRAYS_H
#define TEST_HEADER_DATA_ARRAYS_H

#include <time.h>

#define MY_INT unsigned long long

namespace arrays {

    // inspired from "laser.h"
    struct D1 {
        int sec;
        unsigned int usec;
        double ranges[256];
        MY_INT a;
    };

    // simple array
    double A1[3];

    // two-dimensional array -- not detected
    double A2[3][5];

    // array of records -- also not detected
    struct timespec A3[2];

    /// more text, formatted to be able to be extracted as a
    /// "clang::comments::FullComment".
    ///
    /// blalba. more text. the same wrapped inside a container -- detected and exported
    class C1 {
      public:
        struct timespec A3[2];
        int m1;
    };

}

#endif /*TEST_HEADER_DATA_ARRAYS_H*/
