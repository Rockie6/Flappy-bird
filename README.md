# 🎮 Flappy Bird AI - Genetic Algorithm Game

A collection of Flappy Bird implementations featuring AI players that learn through genetic algorithms and neural networks.

## 🚀 Features

### 🧬 Genetic Algorithm AI (`flappy_ai.py`)
- **Population-based learning**: 20 AI birds evolve over generations
- **Neural networks**: Each bird has a simple 4-input neural network brain
- **Genetic evolution**: Selection, mutation, and elitism
- **Real-time visualization**: Watch AI birds learn to play Flappy Bird
- **Performance tracking**: Monitor fitness scores across generations

### 🎯 Human vs AI (`flappy_playable.py`)  
- **Competitive gameplay**: Play against 3 AI opponents
- **Real-time competition**: See who gets the highest score
- **Beautiful graphics**: Gradient backgrounds, clouds, and detailed sprites
- **Intuitive controls**: SPACE to flap, R to restart
- **Score tracking**: Live scoring with winner determination

### 🔧 Jaclang Versions
- **flappy_simple.jac**: Simplified Jaclang implementation
- **flappy_ai_complete.jac**: Full-featured Jaclang version
- **flappy_bird_ai.jac**: Advanced Jaclang genetic algorithm

## 🎮 How to Play

### Quick Setup (Recommended)
```bash
# Clone the repository
git clone https://github.com/Rockie6/Flappy-bird.git
cd Flappy-bird

# Create virtual environment
python3 -m venv flappy_env

# Activate virtual environment
source flappy_env/bin/activate  # Linux/macOS
# OR
flappy_env\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Play the game!
python flappy_playable.py
```

### Alternative Installation
```bash
# If you prefer system-wide installation (not recommended)
sudo apt install python3-pygame python3-numpy python3-matplotlib python3-scipy  # Ubuntu/Debian
# OR
pip install --break-system-packages pygame numpy matplotlib scipy  # Override protection

# Then run
python3 flappy_playable.py
```

### Human vs AI Competition
```bash
python flappy_playable.py
```
- **🔴 Red Bird**: You (controlled with SPACE)
- **🔵🟢🟡 AI Birds**: Neural network opponents
- **Objective**: Get the highest score!

## 🧠 How the AI Works

### Neural Network Architecture
- **Inputs (4)**:
  - Bird Y position (normalized)
  - Bird velocity (normalized)  
  - Distance to next pipe (normalized)
  - Gap center height (normalized)
- **Output (1)**: Flap decision (sigmoid activation)

### Genetic Algorithm Process
1. **Selection**: Tournament selection of best performers
2. **Elitism**: Top performers survive to next generation
3. **Mutation**: Random weight/bias adjustments
4. **Fitness**: Survival time + score-based evaluation

### Evolution Parameters
- Population size: 20 birds
- Generations: 20 (configurable)
- Mutation rate: 15%
- Elite count: 3 birds
- Tournament size: 3 birds

## 📊 Performance

Typical learning progression:
- **Generation 1**: ~50-80 points average
- **Generation 5**: ~100-150 points average  
- **Generation 10+**: ~200+ points average
- **Best recorded**: 500+ points
- 
### Code Structure
```
flappy_ai.py           # Main genetic algorithm implementation
flappy_playable.py     # Human vs AI competitive version
*.jac                  # Jaclang experimental versions
README.md              # This documentation
requirements.txt       # Python dependencies
```

## 🎯 Future Enhancements

- [ ] **Advanced Neural Networks**: Deep learning with hidden layers
- [ ] **NEAT Algorithm**: Topology-evolving neural networks  
- [ ] **Reinforcement Learning**: Q-learning implementation
- [ ] **Multiplayer Mode**: Online competition
- [ ] **Mobile Version**: Touch controls for mobile devices
- [ ] **Sound Effects**: Audio feedback and music
- [ ] **Leaderboards**: Persistent high score tracking

## 🏆 High Scores

| Player Type | Best Score | Date |
|-------------|-----------|------|
| Human | 188 | 2025-09-28 |
| AI (Gen 1) | 83.6 | 2025-09-28 |
| AI (Gen 2) | 126.5 | 2025-09-28 |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **pygame**: For the graphics and game engine
- **numpy**: For numerical computations
- **Genetic algorithms**: Inspired by evolutionary biology
- **Flappy Bird**: Original game concept by Dong Nguyen

## 📞 Contact

- **GitHub**: [https://github.com/Rockie6]
- **Project**: [https://github.com/Rockie6/Flappy-bird.git]

---

*Made with ❤️ and lots of ☕ by Rockie*
