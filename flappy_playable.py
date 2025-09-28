#!/usr/bin/env python3
"""
Playable Flappy Bird with AI Competition
Human vs AI - See who can get the highest score!
"""

import pygame
import random
import math
import sys

class Bird:
    def __init__(self, x=100, y=300, color=(255, 255, 0), is_ai=True):
        self.x = x
        self.y = y
        self.velocity = 0.0
        self.alive = True
        self.score = 0
        self.color = color
        self.is_ai = is_ai
        self.brain = self.create_random_brain() if is_ai else None
    
    def create_random_brain(self):
        """Create AI brain with pre-trained weights (simplified)"""
        return {
            "weights": [random.uniform(-1.5, 1.5) for _ in range(4)],
            "bias": random.uniform(-0.5, 0.5)
        }
    
    def think(self, pipes):
        """AI decision making"""
        if not self.is_ai:
            return False  # Human controls manually
            
        # Find closest pipe
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
        
        # Neural network inputs
        inputs = [
            self.y / 600.0,
            self.velocity / 10.0,
            (closest_pipe.x - self.x) / 400.0,
            ((closest_pipe.top_height + closest_pipe.bottom_height) / 2) / 600.0
        ]
        
        # Simple neural network
        output = self.brain["bias"]
        for i in range(4):
            output += inputs[i] * self.brain["weights"][i]
        
        activated = 1.0 / (1.0 + math.exp(-max(-500, min(500, output))))
        return activated > 0.5
    
    def update(self):
        """Update bird physics"""
        self.velocity += 0.4  # gravity
        self.y += self.velocity
        
        # Check bounds
        if self.y <= 0 or self.y >= 580:
            self.alive = False
    
    def flap(self):
        """Make bird flap"""
        if self.alive:
            self.velocity = -7.0
    
    def draw(self, screen):
        """Draw the bird"""
        if self.alive:
            pygame.draw.circle(screen, self.color, (int(self.x), int(self.y)), 12)
            # Draw eye
            pygame.draw.circle(screen, (0, 0, 0), (int(self.x) + 4, int(self.y) - 4), 3)
            # Draw beak
            beak_points = [(int(self.x) + 12, int(self.y)), (int(self.x) + 18, int(self.y) + 2), (int(self.x) + 12, int(self.y) + 4)]
            pygame.draw.polygon(screen, (255, 165, 0), beak_points)

class Pipe:
    def __init__(self, x):
        self.x = x
        self.width = 80
        self.speed = 2.0
        self.reset_height()
    
    def reset_height(self):
        """Randomize pipe gap"""
        gap_center = random.uniform(180, 420)
        gap_size = 180
        self.top_height = gap_center - gap_size // 2
        self.bottom_height = gap_center + gap_size // 2
    
    def update(self):
        """Move pipe left"""
        self.x -= self.speed
    
    def collides_with(self, bird):
        """Check collision with bird"""
        bird_radius = 12
        
        if (bird.x + bird_radius > self.x and 
            bird.x - bird_radius < self.x + self.width):
            
            if (bird.y - bird_radius < self.top_height or 
                bird.y + bird_radius > self.bottom_height):
                return True
        return False
    
    def passed_by(self, bird):
        """Check if bird passed this pipe"""
        return bird.x > self.x + self.width
    
    def draw(self, screen):
        """Draw pipe"""
        # Top pipe (green with gradient)
        pygame.draw.rect(screen, (0, 128, 0), (self.x, 0, self.width, self.top_height))
        pygame.draw.rect(screen, (0, 100, 0), (self.x, 0, 5, self.top_height))  # Shadow
        
        # Bottom pipe (green with gradient)  
        pygame.draw.rect(screen, (0, 128, 0), (self.x, self.bottom_height, self.width, 600 - self.bottom_height))
        pygame.draw.rect(screen, (0, 100, 0), (self.x, self.bottom_height, 5, 600 - self.bottom_height))  # Shadow

class FlappyGame:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((800, 600))
        pygame.display.set_caption("Flappy Bird: Human vs AI")
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(None, 36)
        self.big_font = pygame.font.Font(None, 48)
        
        self.pipes = []
        self.pipe_timer = 0
        self.pipe_spacing = 200
        
        self.game_over = False
        self.winner = None
        
        # Create players
        self.human = Bird(x=100, y=250, color=(255, 100, 100), is_ai=False)  # Red human
        self.ai_birds = [
            Bird(x=100, y=300, color=(100, 100, 255), is_ai=True),  # Blue AI 1
            Bird(x=100, y=350, color=(100, 255, 100), is_ai=True),  # Green AI 2
            Bird(x=100, y=200, color=(255, 255, 100), is_ai=True),  # Yellow AI 3
        ]
        
        self.all_birds = [self.human] + self.ai_birds
        self.create_initial_pipes()
        
        print("🎮 Flappy Bird: Human vs AI")
        print("🔴 RED bird = YOU (SPACE to flap)")
        print("🔵 BLUE, 🟢 GREEN, 🟡 YELLOW birds = AI")
        print("Press SPACE to flap, ESC to quit")
    
    def create_initial_pipes(self):
        """Create initial set of pipes"""
        self.pipes = [
            Pipe(400),
            Pipe(600),
            Pipe(800)
        ]
    
    def handle_events(self):
        """Handle user input"""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    self.human.flap()
                    print("🚀 Human flap!")
                elif event.key == pygame.K_ESCAPE:
                    return False
                elif event.key == pygame.K_r and self.game_over:
                    self.restart_game()
        return True
    
    def restart_game(self):
        """Restart the game"""
        self.game_over = False
        self.winner = None
        
        # Reset human
        self.human = Bird(x=100, y=250, color=(255, 100, 100), is_ai=False)
        
        # Reset AI birds with new brains
        self.ai_birds = [
            Bird(x=100, y=300, color=(100, 100, 255), is_ai=True),
            Bird(x=100, y=350, color=(100, 255, 100), is_ai=True), 
            Bird(x=100, y=200, color=(255, 255, 100), is_ai=True),
        ]
        
        self.all_birds = [self.human] + self.ai_birds
        self.create_initial_pipes()
        print("🔄 Game restarted!")
    
    def update_pipes(self):
        """Update pipe positions and create new ones"""
        for pipe in self.pipes:
            pipe.update()
        
        # Remove pipes that are off screen and add new ones
        self.pipes = [pipe for pipe in self.pipes if pipe.x > -pipe.width]
        
        # Add new pipe if needed
        if len(self.pipes) < 4 and (not self.pipes or self.pipes[-1].x < 600):
            new_x = self.pipes[-1].x + self.pipe_spacing if self.pipes else 400
            self.pipes.append(Pipe(new_x))
    
    def update_birds(self):
        """Update all birds"""
        alive_count = 0
        
        for bird in self.all_birds:
            if not bird.alive:
                continue
                
            alive_count += 1
            
            # AI decision making
            if bird.is_ai and bird.think(self.pipes):
                bird.flap()
            
            # Update physics
            bird.update()
            
            # Check pipe collisions
            for pipe in self.pipes:
                if pipe.collides_with(bird):
                    bird.alive = False
                    if bird == self.human:
                        print(f"💀 Human died! Score: {bird.score}")
                    else:
                        print(f"🤖 AI bird died! Score: {bird.score}")
                    break
            
            # Update score when passing pipes
            if bird.alive:
                for pipe in self.pipes:
                    if pipe.passed_by(bird) and pipe.x + pipe.width < bird.x - 5:
                        bird.score += 1
                        if bird == self.human:
                            print(f"🎯 Human score: {bird.score}")
                        break
        
        # Check if game over
        if alive_count == 0:
            self.end_game()
    
    def end_game(self):
        """End the game and determine winner"""
        self.game_over = True
        
        # Find the winner (highest score)
        scores = [(bird.score, "Human" if bird == self.human else f"AI-{['Blue', 'Green', 'Yellow'][self.ai_birds.index(bird)] if bird in self.ai_birds else 'Unknown'}") 
                 for bird in self.all_birds]
        scores.sort(key=lambda x: x[0], reverse=True)
        
        self.winner = scores[0]
        print(f"\n🏆 GAME OVER!")
        print(f"🥇 Winner: {self.winner[1]} with score {self.winner[0]}")
        print("📊 Final Scores:")
        for score, name in scores:
            print(f"   {name}: {score}")
        print("Press R to restart, ESC to quit")
    
    def draw_background(self):
        """Draw background"""
        # Sky gradient
        for y in range(600):
            color_intensity = 135 + int((206 - 135) * y / 600)
            color = (color_intensity, 206, 235)
            pygame.draw.line(self.screen, color, (0, y), (800, y))
        
        # Draw clouds
        cloud_positions = [(100, 80), (300, 120), (500, 60), (700, 100)]
        for x, y in cloud_positions:
            pygame.draw.circle(self.screen, (255, 255, 255), (x, y), 30)
            pygame.draw.circle(self.screen, (255, 255, 255), (x + 25, y), 25)
            pygame.draw.circle(self.screen, (255, 255, 255), (x - 25, y), 25)
    
    def draw_ui(self):
        """Draw user interface"""
        # Draw scores
        y_offset = 10
        
        # Human score
        human_text = f"🔴 Human: {self.human.score}"
        human_surface = self.font.render(human_text, True, (255, 100, 100))
        self.screen.blit(human_surface, (10, y_offset))
        y_offset += 35
        
        # AI scores
        colors = [(100, 100, 255), (100, 255, 100), (255, 255, 100)]
        names = ["🔵 AI-Blue", "🟢 AI-Green", "🟡 AI-Yellow"]
        
        for i, (bird, color, name) in enumerate(zip(self.ai_birds, colors, names)):
            ai_text = f"{name}: {bird.score}"
            ai_surface = self.font.render(ai_text, True, color)
            self.screen.blit(ai_surface, (10, y_offset))
            y_offset += 35
        
        # Draw instructions
        if not self.game_over:
            instruction = "SPACE = Flap | ESC = Quit"
            inst_surface = self.font.render(instruction, True, (0, 0, 0))
            self.screen.blit(inst_surface, (10, 550))
    
    def draw_game_over(self):
        """Draw game over screen"""
        if not self.game_over:
            return
            
        # Semi-transparent overlay
        overlay = pygame.Surface((800, 600))
        overlay.set_alpha(128)
        overlay.fill((0, 0, 0))
        self.screen.blit(overlay, (0, 0))
        
        # Game over text
        game_over_text = "GAME OVER!"
        game_over_surface = self.big_font.render(game_over_text, True, (255, 255, 255))
        text_rect = game_over_surface.get_rect(center=(400, 200))
        self.screen.blit(game_over_surface, text_rect)
        
        # Winner text
        winner_text = f"🏆 Winner: {self.winner[1]} ({self.winner[0]} points)"
        winner_surface = self.font.render(winner_text, True, (255, 255, 0))
        winner_rect = winner_surface.get_rect(center=(400, 250))
        self.screen.blit(winner_surface, winner_rect)
        
        # Restart instructions
        restart_text = "Press R to Restart | ESC to Quit"
        restart_surface = self.font.render(restart_text, True, (255, 255, 255))
        restart_rect = restart_surface.get_rect(center=(400, 350))
        self.screen.blit(restart_surface, restart_rect)
    
    def run(self):
        """Main game loop"""
        running = True
        
        while running:
            running = self.handle_events()
            
            if not self.game_over:
                self.update_pipes()
                self.update_birds()
            
            # Draw everything
            self.draw_background()
            
            # Draw pipes
            for pipe in self.pipes:
                pipe.draw(self.screen)
            
            # Draw birds
            for bird in self.all_birds:
                bird.draw(self.screen)
            
            self.draw_ui()
            self.draw_game_over()
            
            pygame.display.flip()
            self.clock.tick(60)  # 60 FPS for smooth gameplay
        
        pygame.quit()
        print("\n👋 Thanks for playing! Come back anytime!")

def main():
    """Main function"""
    print("=" * 50)
    print("🎮 FLAPPY BIRD: HUMAN vs AI")
    print("=" * 50)
    print("🔴 RED = Human Player (YOU!)")
    print("🔵🟢🟡 = AI Players")
    print("\nControls:")
    print("  SPACE = Flap")
    print("  R = Restart (after game over)")
    print("  ESC = Quit")
    print("\nObjective: Get the highest score!")
    print("=" * 50)
    
    game = FlappyGame()
    game.run()

if __name__ == "__main__":
    main()