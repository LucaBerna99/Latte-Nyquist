# Latte-Nyquist
## Ball and Beam project

Ball and Beam is a classical control system problems. 
The goal is to balance a ball on a beam by adjusting the beam's angle. 
This project, implemented using MATLAB and Simulink, involves designing a controller to stabilize the ball at a desired position on the beam.

Overview of the Project
### System Parameters:
The system is defined by physical parameters 

### State-Space Representation:
The system is modeled using state-space equations. The matrices A, B, C, and D are defined, and a state-space system object sist is created.


### Simulink Models:
The script loads Simulink models.
Simulations are run using these models, and the step response of the system is plotted for comparison between the analytical model and the Simulink model.

### Step Response Analysis:
The step response of the system is analyzed both in open-loop and closed-loop configurations.
The user is prompted to input a desired final position (r_fin) for the ball, which is used to calculate the desired controller parameters.

### Controller Design:
A proportional-derivative controller is designed. The controller is tuned iteratively by adjusting parameters to meet performance criteria, such as settling time (Ta) and overshoot (S).
The controller's effectiveness is evaluated using Bode and Nyquist plots.

### Disturbance Rejection:
The user is asked to input a frequency for a sinusoidal disturbance. The system's response to this disturbance is simulated in Simulink, and the maximum disturbance amplitude that the system can handle while maintaining stability is determined.

### Performance Evaluation:
The script evaluates system performance based on criteria like phase margin, settling time, and overshoot. 
These results are saved in a text file (PRESTAZIONI.txt).
