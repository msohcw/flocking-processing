## Classic Flocking visualisation

This processing sketch illustrates the classic flocking system, where there is emergent behaviour from simple rules. Some added optimization in terms of gridding, and some added behaviour in the form of groups and leaders, and obstacles. 

* N - number of boids
* GROUPS - number of initial groups
* MAX_GROUPS - maximum final groups
* kS - separation constant
* kC - cohesion constant
* kA - alignment constant
* kD - direction constant (follows a leader)
* kO - avoidance constant (avoids obstacle points)
* NEIGHBOUR THRESHOLD - distance to consider neighbours
* AVOID THRESHOLD - distance to consider avoiding other boids
* FENCE SIZE - fence to consider boids within (used for optimising, only consider boids within the same fence/surrounding fences
* VISUALISATION - visualise grid, direction vectors, distance radii
* INTERACTIVE - mouse press to visualise surrounding, else visualise subset of boids
* MAX \_\_\_\_\_\_ - maximum values for various effects
* SPLIT PROBABILITY - probability a boid will split off into another group
* LEAD PROBABILITY - probability a boid will take up leadership
