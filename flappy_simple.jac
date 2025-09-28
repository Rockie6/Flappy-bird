"""Genetic Algorithm Flappy Bird AI"""

import random;
import pygame;
import math;

walker FlappyAI {
    has population_size: int = 15;
    has generation: int = 0;
    has best_score: float = 0.0;

    can start with `root entry {
        print("=== Genetic Flappy Bird AI ===");
        print("Initializing pygame...");
        
        pygame.init();
        display = pygame.display.set_mode((800, 600));
        pygame.display.set_caption("Genetic Flappy Bird AI");
        clock = pygame.time.Clock();
        
        print("Creating initial population...");
        birds = [];
        for i in range(self.population_size) {
            bird = {
                "x": 100.0,
                "y": 300.0,
                "velocity": 0.0,
                "alive": True,
                "score": 0,
                "fitness": 0.0,
                "brain": self.create_random_brain()
            };
            birds.append(bird);
        }
        
        # Main evolution loop
        for gen in range(5) {  # 5 generations for demo
            self.generation = gen + 1;
            print("=== Generation " + str(self.generation) + " ===");
            
            fitness_scores = self.run_generation(birds, display, clock);
            
            if len(fitness_scores) == 0 {  # User quit
                break;
            }
            
            best_fitness = max(fitness_scores);
            if best_fitness > self.best_score {
                self.best_score = best_fitness;
            }
            
            print("Best fitness this generation: " + str(best_fitness));
            print("All-time best: " + str(self.best_score));
            
            # Create next generation
            if gen < 4 {  # Not last generation
                birds = self.create_next_generation(birds, fitness_scores);
            }
        }
        
        pygame.quit();
        print("Evolution complete! Best score: " + str(self.best_score));
    }

    can create_random_brain() -> dict {
        weights = [];
        for i in range(4) {
            weights.append(random.uniform(-2.0, 2.0));
        }
        
        return {
            "weights": weights,
            "bias": random.uniform(-1.0, 1.0)
        };
    }

    can think(bird: dict, pipes: list) -> bool {
        # Get closest pipe
        closest_pipe = None;
        min_distance = 999999;
        
        for pipe in pipes {
            if pipe["x"] > bird["x"] - 50 {
                distance = abs(pipe["x"] - bird["x"]);
                if distance < min_distance {
                    min_distance = distance;
                    closest_pipe = pipe;
                }
            }
        }
        
        if closest_pipe is None {
            closest_pipe = pipes[0];
        }
        
        # Neural network inputs
        inputs = [
            bird["y"] / 600.0,  # normalized y position
            bird["velocity"] / 10.0,  # normalized velocity  
            (closest_pipe["x"] - bird["x"]) / 400.0,  # distance to pipe
            ((closest_pipe["top_height"] + closest_pipe["bottom_height"]) / 2) / 600.0  # gap center
        ];
        
        # Simple neural network calculation
        output = bird["brain"]["bias"];
        for i in range(4) {
            output += inputs[i] * bird["brain"]["weights"][i];
        }
        
        # Sigmoid activation
        activated = 1.0 / (1.0 + math.exp(-max(-500, min(500, output))));
        
        return activated > 0.5;  # Should flap?
    }

    can run_generation(birds: list, display, clock) -> list {
        # Create pipes
        pipes = [
            {"x": 400.0, "top_height": 150.0, "bottom_height": 450.0, "width": 80.0},
            {"x": 600.0, "top_height": 200.0, "bottom_height": 400.0, "width": 80.0},
            {"x": 800.0, "top_height": 100.0, "bottom_height": 500.0, "width": 80.0}
        ];
        
        frame_count = 0;
        max_frames = 800;  # Reduced for faster testing
        
        # Reset all birds
        for bird in birds {
            bird["x"] = 100.0;
            bird["y"] = 300.0;
            bird["velocity"] = 0.0;
            bird["alive"] = True;
            bird["score"] = 0;
            bird["fitness"] = 0.0;
        }
        
        while frame_count < max_frames {
            # Handle pygame events
            for event in pygame.event.get() {
                if event.type == pygame.QUIT {
                    return [];  # User wants to quit
                }
            }
            
            alive_birds = [];
            for bird in birds {
                if bird["alive"] {
                    alive_birds.append(bird);
                }
            }
            if len(alive_birds) == 0 {
                break;  # All birds dead
            }
            
            # Update pipes
            for pipe in pipes {
                pipe["x"] -= 2.0;  # Move pipes left
                if pipe["x"] < -pipe["width"] {
                    pipe["x"] = 800.0 + random.uniform(0, 100);
                    # Randomize pipe height
                    gap_center = random.uniform(150, 450);
                    pipe["top_height"] = gap_center - 100;
                    pipe["bottom_height"] = gap_center + 100;
                }
            }
            
            # Update birds
            for bird in alive_birds {
                # Neural network decision
                if self.think(bird, pipes) {
                    bird["velocity"] = -7.0;  # Flap
                }
                
                # Physics
                bird["velocity"] += 0.4;  # Gravity
                bird["y"] += bird["velocity"];
                
                # Check collisions
                dead = False;
                
                # Ground/ceiling collision
                if bird["y"] <= 0 or bird["y"] >= 580 {
                    dead = True;
                }
                
                # Pipe collision
                if not dead {
                    for pipe in pipes {
                        if (bird["x"] + 15 > pipe["x"] and bird["x"] - 15 < pipe["x"] + pipe["width"]) {
                            if (bird["y"] - 15 < pipe["top_height"] or bird["y"] + 15 > pipe["bottom_height"]) {
                                dead = True;
                                break;
                            }
                        }
                    }
                }
                
                if dead {
                    bird["alive"] = False;
                    bird["fitness"] = bird["score"] + frame_count * 0.1;
                } else {
                    bird["score"] += 1;
                }
            }
            
            # Draw everything
            self.draw_frame(display, alive_birds, pipes, frame_count);
            
            frame_count += 1;
            clock.tick(40);  # 40 FPS
        }
        
        # Calculate final fitness
        for bird in birds {
            if bird["alive"] {
                bird["fitness"] = bird["score"] + frame_count * 0.1;
            }
        }
        
        fitness_list = [];
        for bird in birds {
            fitness_list.append(bird["fitness"]);
        }
        return fitness_list;
    }

    can draw_frame(display, birds: list, pipes: list, frame: int) -> None {
        # Clear screen - sky blue
        display.fill((135, 206, 235));
        
        # Draw pipes
        for pipe in pipes {
            # Top pipe (green)
            pygame.draw.rect(display, (0, 128, 0), 
                           (pipe["x"], 0, pipe["width"], pipe["top_height"]));
            # Bottom pipe (green)  
            pygame.draw.rect(display, (0, 128, 0), 
                           (pipe["x"], pipe["bottom_height"], pipe["width"], 
                            600 - pipe["bottom_height"]));
        }
        
        # Draw birds
        for i, bird in enumerate(birds) {
            if bird["alive"] {
                # Best bird is yellow, others are white
                color = (255, 255, 0) if i == 0 else (255, 255, 255);
                pygame.draw.circle(display, color, 
                                 (int(bird["x"]), int(bird["y"])), 12);
                
                # Draw small eye
                pygame.draw.circle(display, (0, 0, 0), 
                                 (int(bird["x"]) + 4, int(bird["y"]) - 4), 3);
            }
        }
        
        # Draw stats
        font = pygame.font.Font(None, 32);
        stats = "Gen: " + str(self.generation) + "  Alive: " + str(len(birds)) + "  Best: " + str(self.best_score);
        text_surface = font.render(stats, True, (0, 0, 0));
        display.blit(text_surface, (10, 10));
        
        frame_text = "Frame: " + str(frame);
        frame_surface = font.render(frame_text, True, (0, 0, 0));
        display.blit(frame_surface, (10, 45));
        
        pygame.display.flip();
    }

    can create_next_generation(birds: list, fitness_scores: list) -> list {
        # Sort birds by fitness
        bird_fitness_pairs = list(zip(birds, fitness_scores));
        bird_fitness_pairs.sort(key=lambda x: x[1], reverse=True);
        
        new_birds = [];
        
        # Keep top 3 (elites)
        for i in range(min(3, len(bird_fitness_pairs))) {
            elite_bird = bird_fitness_pairs[i][0];
            new_bird = {
                "x": 100.0,
                "y": 300.0,
                "velocity": 0.0,
                "alive": True,
                "score": 0,
                "fitness": 0.0,
                "brain": dict(elite_bird["brain"])  # Copy brain
            };
            new_birds.append(new_bird);
        }
        
        # Fill rest with mutated offspring
        while len(new_birds) < self.population_size {
            # Tournament selection
            parent = self.tournament_selection(bird_fitness_pairs);
            
            # Create child with mutation
            child = {
                "x": 100.0,
                "y": 300.0,
                "velocity": 0.0,
                "alive": True,
                "score": 0,
                "fitness": 0.0,
                "brain": dict(parent["brain"])  # Copy parent brain
            };
            
            self.mutate_brain(child["brain"]);
            new_birds.append(child);
        }
        
        return new_birds;
    }

    can tournament_selection(bird_fitness_pairs: list) -> dict {
        tournament_size = 3;
        tournament = random.sample(bird_fitness_pairs, min(tournament_size, len(bird_fitness_pairs)));
        tournament.sort(key=lambda x: x[1], reverse=True);
        return tournament[0][0];
    }

    can mutate_brain(brain: dict) -> None {
        mutation_rate = 0.15;
        mutation_strength = 0.3;
        
        # Mutate weights
        for i in range(len(brain["weights"])) {
            if random.random() < mutation_rate {
                brain["weights"][i] += random.uniform(-mutation_strength, mutation_strength);
                brain["weights"][i] = max(-3.0, min(3.0, brain["weights"][i]));  # Clamp
            }
        }
        
        # Mutate bias
        if random.random() < mutation_rate {
            brain["bias"] += random.uniform(-mutation_strength, mutation_strength);
            brain["bias"] = max(-3.0, min(3.0, brain["bias"]));  # Clamp
        }
    }
}

with entry:__main__ {
    print("Starting Genetic Flappy Bird AI...");
    ai = FlappyAI() spawn root;
}