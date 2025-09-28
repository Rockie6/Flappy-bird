"""Flappy Bird AI with Genetic Algorithm"""
import random;
import from byllm.llm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

"""Provide evolutionary strategy suggestions for the genetic algorithm"""
def suggest_evolution_strategy(generation: int, best_score: int, avg_score: int) -> str by llm();

walker Bird {
    has brain;  # Neural network weights
    has fitness: int = 0;
    has position: list = [100, 300];
    has velocity: float = 0.0;
    has alive: bool = true;
    
    can simulate with entry {
        # Bird simulation logic
        score = 0;
        .position = [100, 300];
        .velocity = 0.0;
        .alive = true;
        
        # Simple simulation - flap randomly
        for step in range(200) {
            if not .alive {
                break;
            }
            
            # Neural network decision would go here
            if random.random() > 0.7 {
                .velocity = -4.0;
            }
            
            # Physics
            .velocity += 0.5;
            .position[1] += .velocity;
            
            # Collision detection
            if .position[1] <= 0 or .position[1] >= 600 {
                .alive = false;
            } else {
                score += 1;
            }
        }
        
        .fitness = score;
    }
    
    can mutate with entry {
        # Mutation logic
        if .brain and random.random() < 0.1 {
            # Simple mutation - randomize some weights
            for i in range(len(.brain)) {
                if hasattr(.brain[i], '__iter__'):
                    for j in range(len(.brain[i])):
                        if random.random() < 0.1:
                            .brain[i][j] += random.uniform(-0.5, 0.5);
                else:
                    if random.random() < 0.1:
                        .brain[i] += random.uniform(-0.5, 0.5);
            }
        }
    }
}

walker FlappyEvolution {
    has population_size: int = 20;
    has generation: int = 0;
    has best_score: int = 0;
    has mutation_rate: float = 0.1;
    
    can evolve with entry {
        # Initialize population
        birds = [];
        for i in range(.population_size) {
            birds.append({
                "brain": .create_neural_network(),
                "fitness": 0,
                "position": [100, 300],
                "velocity": 0.0,
                "alive": true
            });
        }
        
        # Evolution loop
        for gen in range(10) {  # Reduced to 10 gens for testing
            .generation = gen;
            print(f"🎯 Generation {.generation}");
            
            # Test each bird
            total_score = 0;
            best_gen_score = 0;
            
            for bird in birds {
                # Create bird walker and simulate
                bird_walker = spawn here walker::Bird(
                    brain=bird["brain"],
                    position=bird["position"].copy(),
                    velocity=bird["velocity"]
                );
                bird_walker.simulate();
                
                bird["fitness"] = bird_walker.fitness;
                total_score += bird_walker.fitness;
                
                if bird_walker.fitness > best_gen_score:
                    best_gen_score = bird_walker.fitness;
                
                if bird_walker.fitness > .best_score:
                    .best_score = bird_walker.fitness;
            }
            
            # Calculate statistics
            avg_score = total_score / len(birds);
            
            # Get AI suggestions for evolution
            strategy = suggest_evolution_strategy(.generation, .best_score, avg_score);
            print(f"🤖 AI Suggestion: {strategy}");
            
            # Create new generation (except after last generation)
            if gen < 9:
                birds = .create_new_generation(birds);
            
            print(f"   Best: {best_gen_score} | Average: {avg_score:.1f} | Overall Best: {.best_score}");
        }
        
        print(f"✅ Evolution complete! Final best score: {.best_score}");
    }
    
    can create_neural_network with entry {
        # Simple neural network structure
        return [
            [random.uniform(-1, 1) for _ in range(4)],  # Input to hidden
            [random.uniform(-1, 1) for _ in range(4)],  # Hidden to output
        ];
    }
    
    can create_new_generation(birds: list) -> list with entry {
        # Sort by fitness
        sorted_birds = sorted(birds, key=lambda x: x["fitness"], reverse=True);
        
        new_population = [];
        population_size = len(birds);
        
        # Keep top 30%
        keep_count = max(1, population_size // 3);
        for i in range(keep_count):
            new_population.append(sorted_birds[i]);
        
        # Breed new birds
        while len(new_population) < population_size:
            parent1 = random.choice(sorted_birds[:keep_count]);
            parent2 = random.choice(sorted_birds[:keep_count]);
            
            # Simple crossover - alternate weights
            child_brain = [];
            for i in range(len(parent1["brain"])):
                layer = [];
                for j in range(len(parent1["brain"][i])):
                    if random.random() > 0.5:
                        layer.append(parent1["brain"][i][j]);
                    else:
                        layer.append(parent2["brain"][i][j]);
                child_brain.append(layer);
            
            # Mutation
            if random.random() < .mutation_rate:
                for i in range(len(child_brain)):
                    for j in range(len(child_brain[i])):
                        if random.random() < 0.1:
                            child_brain[i][j] += random.uniform(-0.5, 0.5);
            
            new_population.append({
                "brain": child_brain,
                "fitness": 0,
                "position": [100, 300],
                "velocity": 0.0,
                "alive": true
            });
        
        return new_population;
    }
}

# Run the evolution
with entry {
    print("🚀 Starting Flappy Bird AI Evolution");
    evolution = spawn here walker::FlappyEvolution();
    evolution.evolve();
}