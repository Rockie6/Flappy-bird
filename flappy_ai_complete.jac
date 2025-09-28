import pygame;
import random;
import math;

obj Bird {
    has x: float = 100.0, y: float = 300.0;
    has velocity: float = 0.0;
    has alive: bool = True;
    has score: int = 0;
    has fitness: float = 0.0;
    has brain: dict = {};
    
    def update_physics() -> None {
        self.velocity += 0.5;  # gravity
        self.y += self.velocity;
    }
    
    def flap() -> None {
        self.velocity = -8.0;
    }
    
    def is_dead() -> bool {
        return self.y <= 0 or self.y >= 580;
    }
}

obj Pipe {
    has x: float;
    has top_height: float;
    has bottom_height: float;
    has width: float = 80.0;
    
    def move() -> None {
        self.x -= 3.0;
    }
    
    def reset(new_x: float) -> None {
        self.x = new_x;
        gap_center = random.uniform(150, 450);
        self.top_height = gap_center - 100;
        self.bottom_height = gap_center + 100;
    }
    
    def collides_with(bird: Bird) -> bool {
        if (bird.x + 15 > self.x and bird.x - 15 < self.x + self.width) {
            return (bird.y - 15 < self.top_height or bird.y + 15 > self.bottom_height);
        }
        return False;
    }
}

walker FlappyAI {
    has population_size: int = 20;
    has generation: int = 0;
    has best_score: float = 0.0;
    has display;
    has clock;
    has birds: list = [];
    has pipes: list = [];
    
    can initialize_game with entry {
        print("Initializing Flappy Bird AI...");
        
        pygame.init();
        self.display = pygame.display.set_mode((800, 600));
        pygame.display.set_caption("Genetic Flappy Bird AI");
        self.clock = pygame.time.Clock();
        
        # Create pipes
        self.pipes = [
            Pipe(x=400.0, top_height=150.0, bottom_height=450.0),
            Pipe(x=600.0, top_height=200.0, bottom_height=400.0),
            Pipe(x=800.0, top_height=100.0, bottom_height=500.0)
        ];
        
        print("Game initialized successfully!");
        return True;
    }
    
    can create_population with entry {
        self.birds = [];
        for i in range(self.population_size) {
            bird = Bird();
            bird.brain = self.create_random_brain();
            self.birds.append(bird);
        }
        print(f"Created population of {self.population_size} birds");
    }
    
    can create_random_brain() -> dict {
        return {
            "weights": [random.uniform(-2.0, 2.0) for _ in range(4)],
            "bias": random.uniform(-1.0, 1.0)
        };
    }
    
    can think(bird: Bird) -> bool {
        # Get inputs for neural network
        closest_pipe = self.get_closest_pipe(bird);
        
        inputs = [
            bird.y / 600.0,  # normalized y position
            bird.velocity / 10.0,  # normalized velocity
            (closest_pipe.x - bird.x) / 400.0,  # distance to pipe
            ((closest_pipe.top_height + closest_pipe.bottom_height) / 2) / 600.0  # gap center
        ];
        
        # Simple neural network calculation
        output = bird.brain["bias"];
        for i in range(4) {
            output += inputs[i] * bird.brain["weights"][i];
        }
        
        # Sigmoid activation
        activated = 1.0 / (1.0 + math.exp(-max(-500, min(500, output))));
        
        return activated > 0.5;  # Should flap?
    }
    
    can get_closest_pipe(bird: Bird) -> Pipe {
        closest = self.pipes[0];
        min_distance = abs(closest.x - bird.x);
        
        for pipe in self.pipes {
            distance = abs(pipe.x - bird.x);
            if pipe.x > bird.x - 50 and distance < min_distance {
                closest = pipe;
                min_distance = distance;
            }
        }
        return closest;
    }
    
    can run_generation() -> list {
        frame_count = 0;
        max_frames = 1000;
        
        # Reset birds
        for bird in self.birds {
            bird.x = 100.0;
            bird.y = 300.0;
            bird.velocity = 0.0;
            bird.alive = True;
            bird.score = 0;
            bird.fitness = 0.0;
        }
        
        while frame_count < max_frames {
            # Handle pygame events
            for event in pygame.event.get() {
                if event.type == pygame.QUIT {
                    return [];
                }
            }
            
            alive_birds = [bird for bird in self.birds if bird.alive];
            if len(alive_birds) == 0 {
                break;
            }
            
            # Update pipes
            for pipe in self.pipes {
                pipe.move();
                if pipe.x < -pipe.width {
                    pipe.reset(800.0 + random.uniform(0, 200));
                }
            }
            
            # Update birds
            for bird in alive_birds {
                # Neural network decision
                if self.think(bird) {
                    bird.flap();
                }
                
                bird.update_physics();
                
                # Check collisions
                dead = bird.is_dead();
                for pipe in self.pipes {
                    if pipe.collides_with(bird) {
                        dead = True;
                        break;
                    }
                }
                
                if dead {
                    bird.alive = False;
                    bird.fitness = bird.score + frame_count * 0.1;
                } else {
                    bird.score += 1;
                }
            }
            
            # Draw everything
            self.draw_frame(alive_birds, frame_count);
            
            frame_count += 1;
            self.clock.tick(30);  # 30 FPS
        }
        
        # Calculate final fitness
        for bird in self.birds {
            if bird.alive {
                bird.fitness = bird.score + frame_count * 0.1;
            }
        }
        
        return [bird.fitness for bird in self.birds];
    }
    
    can draw_frame(alive_birds: list, frame: int) -> None {
        # Clear screen
        self.display.fill((135, 206, 235));  # Sky blue
        
        # Draw pipes
        for pipe in self.pipes {
            pygame.draw.rect(self.display, (0, 128, 0), 
                           (pipe.x, 0, pipe.width, pipe.top_height));
            pygame.draw.rect(self.display, (0, 128, 0), 
                           (pipe.x, pipe.bottom_height, pipe.width, 
                            600 - pipe.bottom_height));
        }
        
        # Draw birds
        for i, bird in enumerate(alive_birds) {
            color = (255, 255, 0) if i == 0 else (255, 255, 255);  # Best bird yellow
            pygame.draw.circle(self.display, color, 
                             (int(bird.x), int(bird.y)), 15);
        }
        
        # Draw stats
        font = pygame.font.Font(None, 36);
        stats = f"Gen: {self.generation}  Alive: {len(alive_birds)}  Best: {self.best_score:.1f}";
        text_surface = font.render(stats, True, (0, 0, 0));
        self.display.blit(text_surface, (10, 10));
        
        pygame.display.flip();
    }
    
    can evolve() -> None {
        print(f"Starting evolution...");
        
        for gen in range(10) {  # 10 generations
            self.generation = gen + 1;
            print(f"Generation {self.generation}");
            
            if gen == 0 {
                self.create_population();
            }
            
            fitness_scores = self.run_generation();
            
            if len(fitness_scores) == 0 {  # User quit
                break;
            }
            
            best_fitness = max(fitness_scores);
            if best_fitness > self.best_score {
                self.best_score = best_fitness;
            }
            
            print(f"Best fitness this generation: {best_fitness:.1f}");
            
            # Create next generation
            if gen < 9 {  # Not last generation
                self.create_next_generation(fitness_scores);
            }
        }
        
        pygame.quit();
        print(f"Evolution complete! Best score achieved: {self.best_score:.1f}");
    }
    
    can create_next_generation(fitness_scores: list) -> None {
        # Sort birds by fitness
        bird_fitness_pairs = list(zip(self.birds, fitness_scores));
        bird_fitness_pairs.sort(key=lambda x: x[1], reverse=True);
        
        new_birds = [];
        
        # Keep top 5 (elites)
        for i in range(min(5, len(bird_fitness_pairs))) {
            elite_bird = bird_fitness_pairs[i][0];
            new_bird = Bird();
            new_bird.brain = dict(elite_bird.brain);  # Copy brain
            new_birds.append(new_bird);
        }
        
        # Fill rest with mutated offspring
        while len(new_birds) < self.population_size {
            # Select parent (tournament selection)
            parent = self.tournament_selection(bird_fitness_pairs);
            
            # Create child with mutation
            child = Bird();
            child.brain = dict(parent.brain);
            self.mutate_brain(child.brain);
            new_birds.append(child);
        }
        
        self.birds = new_birds;
    }
    
    can tournament_selection(bird_fitness_pairs: list) -> Bird {
        tournament_size = 3;
        tournament = random.sample(bird_fitness_pairs, min(tournament_size, len(bird_fitness_pairs)));
        tournament.sort(key=lambda x: x[1], reverse=True);
        return tournament[0][0];
    }
    
    can mutate_brain(brain: dict) -> None {
        mutation_rate = 0.1;
        mutation_strength = 0.5;
        
        # Mutate weights
        for i in range(len(brain["weights"])) {
            if random.random() < mutation_rate {
                brain["weights"][i] += random.uniform(-mutation_strength, mutation_strength);
                brain["weights"][i] = max(-5.0, min(5.0, brain["weights"][i]));  # Clamp
            }
        }
        
        # Mutate bias
        if random.random() < mutation_rate {
            brain["bias"] += random.uniform(-mutation_strength, mutation_strength);
            brain["bias"] = max(-5.0, min(5.0, brain["bias"]));  # Clamp
        }
    }
}

with entry {
    print("=== Genetic Flappy Bird AI ===");
    print("Close the window or press Ctrl+C to exit");
    
    ai = FlappyAI();
    ai.initialize_game();
    ai.evolve();
}
            
            // Simple neural network decision
            if random(0.0, 1.0) > 0.7 {  // Random flapping for demo
                bird.velocity = -5.0;
            }
            
            // Update physics
            bird.velocity += 0.5;
            bird.position[1] += bird.velocity;
            
            // Simple collision with ground/ceiling
            if bird.position[1] <= 0 or bird.position[1] >= 600 {
                bird.alive = false;
            } else {
                score += 1;
            }
        }
        
        return score;
    }
    
    can create_new_generation with birds entry {
        sorted_birds = birds.sort(key="fitness", reverse=true);
        best_birds = sorted_birds[0:10];
        
        new_population = [];
        
        // Keep elites
        for elite in best_birds[0:5] {
            new_population.append(elite);
        }
        
        // Breed new birds
        while new_population.length < ::population_size {
            parent1 = best_birds[random(0, best_birds.length - 1)];
            parent2 = best_birds[random(0, best_birds.length - 1)];
            child_brain = ::crossover(parent1.brain, parent2.brain);
            ::mutate(child_brain, 0.1);
            
            new_population.append({
                "brain": child_brain,
                "fitness": 0,
                "position": [100, 300],
                "velocity": 0,
                "alive": true
            });
        }
        
        return new_population;
    }
    
    can create_neural_network with input_size, layers entry {
        // Simple neural network structure
        return {
            "input_size": input_size,
            "layers": layers,
            "weights": ::generate_random_weights(input_size, layers),
            "biases": ::generate_random_biases(layers)
        };
    }
    
    can generate_random_weights with input_size, layers entry {
        weights = [];
        prev_size = input_size;
        
        for layer_size in layers {
            layer_weights = [];
            for i in 0..layer_size {
                neuron_weights = [];
                for j in 0..prev_size {
                    neuron_weights.append(random(-1.0, 1.0));
                }
                layer_weights.append(neuron_weights);
            }
            weights.append(layer_weights);
            prev_size = layer_size;
        }
        
        return weights;
    }
    
    can generate_random_biases with layers entry {
        biases = [];
        for layer_size in layers {
            layer_biases = [];
            for i in 0..layer_size {
                layer_biases.append(random(-1.0, 1.0));
            }
            biases.append(layer_biases);
        }
        return biases;
    }
    
    can crossover with parent1, parent2 entry {
        // Simple crossover - alternate between parents
        child = ::create_neural_network(4, [8, 6, 1]);
        
        for i in 0..child.weights.length {
            for j in 0..child.weights[i].length {
                for k in 0..child.weights[i][j].length {
                    if random(0, 1) < 0.5 {
                        child.weights[i][j][k] = parent1.weights[i][j][k];
                    } else {
                        child.weights[i][j][k] = parent2.weights[i][j][k];
                    }
                }
            }
        }
        
        return child;
    }
    
    can mutate with network, mutation_rate entry {
        for i in 0..network.weights.length {
            for j in 0..network.weights[i].length {
                for k in 0..network.weights[i][j].length {
                    if random(0.0, 1.0) < mutation_rate {
                        network.weights[i][j][k] += random(-0.3, 0.3);
                        // Clamp values
                        if network.weights[i][j][k] > 1.0 { network.weights[i][j][k] = 1.0; }
                        if network.weights[i][j][k] < -1.0 { network.weights[i][j][k] = -1.0; }
                    }
                }
            }
        }
    }
    
    can check_exit_event with entry {
        pygame = import("pygame");
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return true;
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    return true;
        return false;
    }
}

// Main execution
walker init {
    has flappy_ai = spawn here ++> walker::flappy_ai;
    
    with entry {
        std.out("Starting Genetic Flappy Bird AI...");
        flappy_ai.init_simulation();
        results = flappy_ai.evolve_population();
        
        std.out("Evolution completed!");
        std.out("Best scores per generation: " + results.str());
    }
}