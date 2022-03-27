#define CL_USE_DEPRECATED_OPENCL_2_0_APIS

#include <CL/cl.hpp>
#include <fstream>
#include <iostream>

int main() {
	std::vector<cl::Platform> platforms;
	cl::Platform::get(&platforms);

	auto platform = platforms.front();
	std::vector<cl::Device> devices;
	platform.getDevices(CL_DEVICE_TYPE_GPU, &devices);

	std::ifstream KERNELgpucode("gpucode.cl");
	std::string src(std::istreambuf_iterator<char>(KERNELgpucode), (std::istreambuf_iterator<char>()));

	cl::Program::Sources sources(1, std::make_pair(src.c_str(), src.length() + 1));

	int rolls[5];
	std::cout << "First roll (excluding leftmost zeros): ";
	std::cin >> rolls[0];
	std::cout << "Second roll (excluding leftmost zeros): ";
	std::cin >> rolls[1];
	std::cout << "Third roll (excluding leftmost zeros): ";
	std::cin >> rolls[2];
	std::cout << "Fourth roll (excluding leftmost zeros): ";
	std::cin >> rolls[3];
	std::cout << "Fifth roll (excluding leftmost zeros): ";
	std::cin >> rolls[4];

	long long out[2];
	for (int i = 0;i < 419096;i++) {
		std::cout << "Pass " << i << "/419096\n";

		int deviceIndex = 0;
		for (auto n = std::begin(devices); n != std::end(devices); ++n) {
			const int in[7] = { i, rolls[0], rolls[1], rolls[2], rolls[3], rolls[4], (((900000000000000/devices.size())*deviceIndex)+100000000000000)/10000000 };

			cl::Context context(devices[deviceIndex]);
			cl::Program program(context, sources);

			auto err = program.build("-cl-std=CL1.2");

			cl::Buffer input(context, CL_MEM_READ_ONLY, sizeof(int) * 7); // Input buffer
			cl::Buffer output(context, CL_MEM_WRITE_ONLY | CL_MEM_HOST_READ_ONLY, sizeof(long long) * 2); // Output buffer

			cl::CommandQueue queue(context, devices[deviceIndex]);
			queue.enqueueWriteBuffer(input, CL_TRUE, 0, sizeof(int) * 7, in);

			cl::Kernel kernel(program, "seedKernel", &err);

			kernel.setArg(0, input);
			kernel.setArg(1, output);

			queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(2147483645));
			queue.finish();

			queue.enqueueReadBuffer(output, CL_TRUE, 0, sizeof(long long) * 2, out); // Read output

			if (out[0] == 777) {
				std::cout << "\nFound seed: " << out[1] << "\n";
				break;
			}

			++deviceIndex;
		}

		if (out[0] == 777) {
			break;
		}
	}

	system("pause");
}