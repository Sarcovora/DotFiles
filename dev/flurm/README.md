**IDEA**
- Format all the hyperparameters you want to test in a dictionary where each hyperparameter is a list
- Generate all combinations of the hyperparams and all the `python main.py <hyperparameters>` commands.
- Using `subprocess`, create a tmux session (and kill it if it already exists). Set the GPU accordingly (`CUDA_VISIBLE_DEVICES`), and then send your command.
NOTE: You'll also want to know how to kill all tmux sessions at once.

