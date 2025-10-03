# 🎮 Flappy Bird AI - Genetic Algorithm Game

A collection of Flappy Bird implementations featuring AI players that learn through genetic algorithms and neural networks.

### 🎯 Human vs AI (`flappy_playable.py`)  
- **Competitive gameplay**: Play against 3 AI opponents
- **Real-time competition**: See who gets the highest score
- **Beautiful graphics**: Gradient backgrounds, clouds, and detailed sprites
- **Intuitive controls**: SPACE to flap, R to restart
- **Score tracking**: Live scoring with winner determination

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

### Genetic Algorithm Process
1. **Selection**: Tournament selection of best performers
2. **Elitism**: Top performers survive to next generation
3. **Mutation**: Random weight/bias adjustments
4. **Fitness**: Survival time + score-based evaluation

- 
### Code Structure
```
flappy_ai.py           # Main genetic algorithm implementation
flappy_playable.py     # Human vs AI competitive version
README.md              # This documentation
requirements.txt       # Python dependencies
```

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

## 📞 Contact:

- **GitHub**: [https://github.com/Rockie6]
- **Project**: [https://github.com/Rockie6/Flappy-bird.git]

---

*Made with ❤️ and lots of ☕ by Rockie*
