#include <gtest/gtest.h>

#include "math_operations.h"

TEST(MathOperationsTest, AddPositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}

TEST(MathOperationsTest, AddNegativeNumbers) {
    EXPECT_EQ(add(-4, -6), -10);
}

TEST(MathOperationsTest, AddPositiveAndNegative) {
    EXPECT_EQ(add(7, -2), 5);
}

TEST(MathOperationsTest, AddWithZero) {
    EXPECT_EQ(add(0, 9), 9);
}
