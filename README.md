# U-IIIC-IS-programming-technologies
The laboratory work on Docker is dedicated to mastering containerization technology for deploying and isolating software applications. We will learn how to create application images using a Dockerfile and then run these images as isolated containers. The work will include practice with essential Docker commands for managing the container lifecycle, configuring volumes for persistent data storage, and using networks to organize interaction between containers. The goal is to acquire the skills necessary for the efficient packaging, deployment, and scaling of applications in an environment-independent format, which is critical for modern DevOps.

---

`Task 0`: Independently find an image and run a container that outputs "Hello world!"

`Task 1`: Write a program according to the chosen option, which was developed in the previous laboratory work. Create a Dockerfile and an image based on it for this program, deploy the image in a container, and demonstrate working with the program via the console in the deployed container.

`Task 2`: Similarly to the first task, deploy a container that will run a program written as a web application. Compare the deployment and operation with a console application and with a web application using Docker.

`Lang`: `C++`

## Structure
```erlang
./
├───t0/
│   └───Dockerfile       %% Docker image's configuration file (runs hello world)
├───t1/
│   ├───artifacts/       %% Container's artifacts
│   ├───src/             %% code
│   ├───tests/           %% tests
│   │   └───unit/
│   └───vendors/         %% vendors (libraries)
│       ├───fmt/
│       ├───gtest
│       └───nlohmann_json
└───t2/
    ├───app.py           %% Web-application
    └───Dockerfile       %% Docker image's configuration file

```
## References

### Libraries
- https://github.com/google/googletest
- https://github.com/fmtlib/fmt
- https://github.com/nlohmann/json

### Docker's pages
- https://docs.docker.com/
- https://docs.docker.com/desktop/setup/install/windows-install/
