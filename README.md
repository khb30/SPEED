# SPEED: a Stochastic Predictor of Early Epidemic Detection

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#examples">Examples</a></li>
        <li><a href="#tests">Tests</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## About The Project

The SPEED model builds on the standard SIR framework by incorporating individual-level testing and diagnosis.
In particular, the model simulates routine yet sparse testing during the initial outbreak stages, with the capacity to escalate to heightened surveillance as part of an incident response strategy

Model simulation is a stochastic process, employing a Gillespie-like algorithm, which is critical for capturing the inherent randomness in early-stage outbreak dynamics.
The intended use of the SPEED framework is for the analysis of early-stage outbreak scenarios, serving two main functionalities: inference and evaluating the time to the next detection.

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>

## Getting Started

This section explaines how to get a local copy of the **SPEED** package and run some example simulations.

### Installation

To install the **SPEED** package , you need to clone the repository from GitHub and install the dependencies.

1. Clone the repo
   ```sh
   git clone https://github.com/khb30/SPEED.git
   ```
2. Change to the package directory:
    ```sh
    cd SPEED
    ```

3. Install the package:
    ```julia
    using Pkg
    Pkg.activate(".")
    Pkg.instantiate()
    ```

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>

### Examples

After installing the package, you can use it by importing it in your Julia scripts.

Three example scripts are provided:

1. `simulation_script.jl`
2. `inference_script.jl`
3. `detections_script.jl`
 
These demonstrate how to run a simulation with configurable parameters such as the maximum number of days for the simulation, population size, diagnosis probability, and different prior distributions.

To run the example script, ensure you are in the working directory of the package and execute the script as shown below:

`julia example_script.jl --days 14 --N 500000 --p 0.0007`

To run code in parallel execute the following, specifying the number of cores:

`julia -p cores example_script.jl --days 14 --N 500000 --p 0.0007 --prior "Uniform" --n 100 --cases 1`

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>

### Tests

To ensure that everything is working correctly, you can run the tests included in the test folder by executing the following command in the package directory:

```julia
    using Pkg
    Pkg.test("SPEED")
```

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>

## License

This project is licensed under the MIT License - see the LICENSE file for details.

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>

## Contact

Kathryn Bowers: khb30@cam.ac.uk

Project Link: [https://github.com/khb30/detection-model](https://github.com/khb30/detection-model)

<p align="right">(<a href="#speed-a-stochastic-predictor-of-early-epidemic-detection">back to top</a>)</p>
