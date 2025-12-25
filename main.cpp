
// How to compile
// g++ -g -O0 -Wall -Wextra -o hello main.cpp

// How to compile with AddressSanitizer and UndefinedBehaviorSanitizer
// g++ -g -O0 -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o hello main.cpp


// Install dependencies (Red Hat based systems)
// sudo dnf install -y libasan libubsan

#include <iostream>
#include <string>

int main() {
	std::string *ptr = NULL;
	ptr->clear(); // crash here
	return 0;
}
