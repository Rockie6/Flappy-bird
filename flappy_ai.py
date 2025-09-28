#!/usr/bin/env python3
"""
Genetic Algorithm Flappy Bird AI
A neural network learns to play Flappy Bird through evolution
"""

import pygame
import random
import math
import sys

class Bird:
    def __init__(self):
        self.x = 100.0
        self.y = 300.0
        self.velocity = 0.0
        self.alive = True
        self.score = 0
        self.fitness = 0.0
        self.brain = self.create_random_brain()
    
    def create_random_brain(self):
        """Create a simple neural network with random weights"""
        return {
            "weights": [random.uniform(-2.0, 2.0) for _ in range(4)],
            "bias": random.uniform(-1.0, 1.0)
        }
    
    def think(self, pipes):
        """Use neural network to decide whether to flap"""
        # Find closest pipe ahead
        closest_pipe = None
        min_distance = float('inf')
        
        for pipe in pipes:
            if pipe.x > self.x - 50:
                distance = abs(pipe.x - self.x)
                if distance < min_distance:
                    min_distance = distance
                    closest_pipe = pipe
        
        if closest_pipe is None:
            closest_pipe = pipes[0]
        
        # Neural network inputs (normalized)
        inputs = [
            self.y / 600.0,  # bird y position
            self.velocity / 10.0,  # bird velocity
            (closest_pipe.x - self.x) / 400.0,  # distance to pipe
            ((closest_pipe.top_height + closest_pipe.bottom_height) / 2) / 600.0  # gap center
        ]
        
        # Simple neural network calculation
        output = self.brain["bias"]
        for i in range(4):
            output += inputs[i] * self.brain["weights"][i]
        
        # Sigmoid activation
        activated = 1.0 / (1.0 + math.exp(-max(-500, min(500, output))))
        
        return activated > 0.5  # Should flap?
    
    def update(self):
        """Update bird physics"""
        self.velocity += 0.4  # gravity
        self.y += self.velocity
        
        # Check bounds
        if self.y <= 0 or self.y >= 580:
            self.alive = False
    
    def flap(self):
        """Make bird flap upward"""
        self.velocity = -7.0
    
    def copy_brain(self):
        """Create a copy of this bird's brain"""
        return {
            "weights": self.brain["weights"].copy(),
            "bias": self.brain["bias"]
        }

class Pipe:
    def __init__(self, x):
        self.x = x
        self.width = 80
        self.reset_height()
    
    def reset_height(self):
        """Randomize pipe gap position"""
        gap_center = random.uniform(150, 450)
        gap_size = 200
        self.top_height = gap_center - gap_size // 2
        self.bottom_height = gap_center + gap_size // 2
    
    def update(self):
        """Move pipe left"""
        self.x -= 2.5
        
        # Reset pipe when it goes off screen
        if self.x < -self.width:
            self.x = 800 + random.uniform(0, 100)
            self.reset_height()
    
    def collides_with(self, bird):
        """Check collision with bird"""
        bird_radius = 12
        
        # Check if bird is in pipe's x range
        if (bird.x + bird_radius > self.x and 
            bird.x - bird_radius < self.x + self.width):
            
            # Check collision with top or bottom pipe
            if (bird.y - bird_radius < self.top_height or 
                bird.y + bird_radius > self.bottom_height):
                return True
        
        return False
    
    def draw(self, screen):
        """Draw pipe on screen"""
        # Top pipe (green)
        pygame.draw.rect(screen, (0, 128, 0), 
                        (self.x, 0, self.width, self.top_height))
        # Bottom pipe (green)
        pygame.draw.rect(screen, (0, 128, 0), 
                        (self.x, self.bottom_height, self.width, 
                         600 - self.bottom_height))

class FlappyAI:
    def __init__(self):
        self.population_size = 20
        self.generation = 0
        self.best_score = 0.0
        self.birds = []
        self.pipes = []
        
        # Initialize pygame
        pygame.init()
        self.screen = pygame.display.set_mode((800, 600))
        pygame.display.set_caption("Genetic Flappy Bird AI")
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(None, 32)
        
        print("🎮 Genetic Flappy Bird AI initialized!")
        print(f"Population size: {self.population_size}")
    
    def create_pipes(self):
        """Create initial pipes"""
        self.pipes = [
            Pipe(400),
            Pipe(600), 
            Pipe(800)
        ]
    
    def create_population(self):
        """Create initial bird population"""
        self.birds = [Bird() for _ in range(self.population_size)]
        print(f"Created population of {self.population_size} birds")
    
    def run_generation(self):
        """Run one generation of the simulation"""
        frame_count = 0
        max_frames = 1000
        
        # Reset all birds
        for bird in self.birds:
            bird.x = 100.0
            bird.y = 300.0
            bird.velocity = 0.0
            bird.alive = True
            bird.score = 0
            bird.fitness = 0.0
        
        self.create_pipes()
        
        while frame_count < max_frames:
            # Handle events
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return None  # User wants to quit
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE:
                        return None
            
            # Get alive birds
            alive_birds = [bird for bird in self.birds if bird.alive]
            if not alive_birds:
                break  # All birds dead
            
            # Update pipes
            for pipe in self.pipes:
                pipe.update()
            
            # Update birds
            for bird in alive_birds:
                # Neural network decision
                if bird.think(self.pipes):
                    bird.flap()
                
                bird.update()
                
                # Check collisions
                if not bird.alive:
                    bird.fitness = bird.score + frame_count * 0.1
                    continue
                
                # Check pipe collisions
                for pipe in self.pipes:
                    if pipe.collides_with(bird):
                        bird.alive = False
                        bird.fitness = bird.score + frame_count * 0.1
                        break
                
                if bird.alive:
                    bird.score += 1
            
            # Draw everything
            self.draw_frame(alive_birds, frame_count)
            
            frame_count += 1
            self.clock.tick(45)  # 45 FPS
        
        # Calculate final fitness for remaining alive birds
        for bird in self.birds:
            if bird.alive:
                bird.fitness = bird.score + frame_count * 0.1
        
        return [bird.fitness for bird in self.birds]
    
    def draw_frame(self, alive_birds, frame):
        """Draw the game frame"""
        # Clear screen - sky blue
        self.screen.fill((135, 206, 235))
        
        # Draw pipes
        for pipe in self.pipes:
            pipe.draw(self.screen)
        
        # Draw birds
        for i, bird in enumerate(alive_birds):
            # Best bird is yellow, others are white
            color = (255, 255, 0) if i == 0 else (255, 255, 255)
            pygame.draw.circle(self.screen, color, 
                             (int(bird.x), int(bird.y)), 12)
            
            # Draw eye
            pygame.draw.circle(self.screen, (0, 0, 0), 
                             (int(bird.x) + 4, int(bird.y) - 4), 3)
        
        # Draw stats
        stats_text = f"Gen: {self.generation}  Alive: {len(alive_birds)}  Best: {self.best_score:.1f}"
        text_surface = self.font.render(stats_text, True, (0, 0, 0))
        self.screen.blit(text_surface, (10, 10))
        
        frame_text = f"Frame: {frame}"
        frame_surface = self.font.render(frame_text, True, (0, 0, 0))
        self.screen.blit(frame_surface, (10, 45))
        
        pygame.display.flip()
    
    def tournament_selection(self, bird_fitness_pairs):
        """Select parent using tournament selection"""
        tournament_size = 3
        tournament = random.sample(bird_fitness_pairs, 
                                 min(tournament_size, len(bird_fitness_pairs)))
        tournament.sort(key=lambda x: x[1], reverse=True)
        return tournament[0][0]
    
    def mutate_brain(self, brain):
        """Mutate brain weights and bias"""
        mutation_rate = 0.15
        mutation_strength = 0.3
        
        # Mutate weights
        for i in range(len(brain["weights"])):
            if random.random() < mutation_rate:
                brain["weights"][i] += random.uniform(-mutation_strength, mutation_strength)
                brain["weights"][i] = max(-3.0, min(3.0, brain["weights"][i]))  # Clamp
        
        # Mutate bias
        if random.random() < mutation_rate:
            brain["bias"] += random.uniform(-mutation_strength, mutation_strength)
            brain["bias"] = max(-3.0, min(3.0, brain["bias"]))  # Clamp
    
    def create_next_generation(self, fitness_scores):
        """Create next generation using genetic algorithm"""
        # Sort birds by fitness
        bird_fitness_pairs = list(zip(self.birds, fitness_scores))
        bird_fitness_pairs.sort(key=lambda x: x[1], reverse=True)
        
        new_birds = []
        
        # Keep top 3 elites
        for i in range(min(3, len(bird_fitness_pairs))):
            elite_bird = bird_fitness_pairs[i][0]
            new_bird = Bird()
            new_bird.brain = elite_bird.copy_brain()
            new_birds.append(new_bird)
        
        # Fill rest with mutated offspring
        while len(new_birds) < self.population_size:
            # Tournament selection for parent
            parent = self.tournament_selection(bird_fitness_pairs)
            
            # Create child with mutation
            child = Bird()
            child.brain = parent.copy_brain()
            self.mutate_brain(child.brain)
            new_birds.append(child)
        
        self.birds = new_birds
    
    def evolve(self):
        """Main evolution loop"""
        print("🧬 Starting evolution...")
        print("Press ESC or close window to exit")
        
        try:
            for generation in range(20):  # 20 generations
                self.generation = generation + 1
                print(f"\n🦅 Generation {self.generation}")
                
                if generation == 0:
                    self.create_population()
                
                fitness_scores = self.run_generation()
                
                if fitness_scores is None:  # User quit
                    print("\n👋 Evolution stopped by user")
                    break
                
                best_fitness = max(fitness_scores) if fitness_scores else 0
                avg_fitness = sum(fitness_scores) / len(fitness_scores) if fitness_scores else 0
                
                if best_fitness > self.best_score:
                    self.best_score = best_fitness
                
                print(f"   Best: {best_fitness:.1f}")
                print(f"   Average: {avg_fitness:.1f}")
                print(f"   All-time best: {self.best_score:.1f}")
                
                # Create next generation (except for last generation)
                if generation < 19:
                    self.create_next_generation(fitness_scores)
        
        except KeyboardInterrupt:
            print("\n⌨️  Evolution stopped by Ctrl+C")
        
        finally:
            pygame.quit()
            print(f"\n🏆 Evolution complete!")
            print(f"🥇 Best score achieved: {self.best_score:.1f}")
            print("Thanks for watching the birds learn to fly! 🐦")

def main():
    """Main function"""
    print("=" * 50)
    print("🎮 GENETIC FLAPPY BIRD AI")
    print("=" * 50)
    print("Watch AI birds learn to play Flappy Bird!")
    print("- Yellow bird is the current best performer")
    print("- White birds are the rest of the population") 
    print("- Birds evolve over generations using genetic algorithms")
    print("=" * 50)
    
    ai = FlappyAI()
    ai.evolve()

if __name__ == "__main__":
    main()