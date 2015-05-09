#include <unistd.h>
#include <math.h>
#include <inttypes.h>

typedef struct vect_i8 {
    int8_t x;
    int8_t y;
    int8_t z;
} vect_i8;

typedef struct vect_f64 {
    double x;
    double y;
    double z;
    int8_t dummy;
} vect_f64;

int dot_product_i8(vect_i8 a, vect_i8 b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

int dot_product_f64(vect_f64 a, vect_f64 b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

vect_i8 conv_f64_to_i8(vect_f64 a)
{
    vect_i8 tmp = { a.x, a.y, a.z };
    return tmp;
}

vect_f64 conv_i8_to_f64(vect_i8 a)
{
    vect_f64 tmp = { a.x, a.y, a.z };
    return tmp;
}
