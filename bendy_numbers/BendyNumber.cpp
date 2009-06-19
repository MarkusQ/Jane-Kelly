#include "BendyNumber.h"
#include <string>
#include <iostream>
#include <sstream>

using namespace std;

BendyNumber::BendyNumber()
{
	value = 0;
}

void BendyNumber::operator=(int val)
{
    value = val;
}

string BendyNumber::operator/(int val)
{
    string numerator,denominator;
    switch (value) {
      case 0:  return "nothing";
      case 1:  numerator = "one ";    break;
      case 2:  numerator = "two ";    break;
      case 3:  numerator = "three ";  break;
      default: numerator = "many ";
	  }
    switch (val) {
      case 0:  denominator = "unicorn";  break;
      case 1:  return numerator;         break;
      case 2:  denominator = "half";     break;
      case 3:  denominator = "third";    break;
      default: denominator = "of many";
	  }
	ostringstream oss;
	oss << numerator << denominator;
    if (value > 1 and val < 4) { oss << "s"; }
	return oss.str();
}
