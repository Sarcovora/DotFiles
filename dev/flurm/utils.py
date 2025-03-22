from itertools import product
import subprocess


def generate_hparam_combinations(hparams):
    """
    Generate all combinations of hyperparameters for a grid search.

    Args:
        hparams (dict): A dictionary where keys are hyperparameter names and
                        values are lists of hyperparameter values.

    Returns:
        list: A list of dictionaries, each representing a unique combination of hyperparameters.
    """
    # Extract keys and values
    keys = hparams.keys()
    values = hparams.values()

    # Generate combinations
    combinations = list(product(*values))

    # Convert to list of dictionaries
    hparam_combinations = [dict(zip(keys, combo)) for combo in combinations]

    return hparam_combinations


def generate_hparam_combinations_for_algorithms(algorithm_hparams):
    """
    Generate all combinations of hyperparameters for multiple algorithms.

    Args:
        algorithm_hparams (dict): A dictionary where keys are algorithm names and
                                  values are dictionaries of hyperparameters for that algorithm.

    Returns:
        dict: A dictionary where keys are algorithm names and values are lists of
              hyperparameter combinations for that algorithm.
    """
    all_combinations = []
    for algorithm, hparams in enumerate(algorithm_hparams):
        all_combinations.extend(generate_hparam_combinations(hparams))
    return all_combinations


def format_hparam_combinations(all_combinations):
    """
    Format hyperparameter combinations as strings in the format "key=value".

    Args:
        all_combinations (dict): A dictionary where keys are algorithm names and
                                 values are lists of hyperparameter combinations.

    Returns:
        dict: A dictionary where keys are algorithm names and values are lists of
              formatted hyperparameter combination strings.
    """
    formatted_combinations = []
    for algorithm, combination in enumerate(all_combinations):
        formatted_combinations.append([" ".join(f"{key}={value}" for key, value in combination.items())])
    return formatted_combinations


def is_tmux_pane_idle(session_name, pane_id="0"):
    """Check if a tmux pane is idle."""
    try:
        # Get information about the target pane
        output = subprocess.check_output(
            ["tmux", "list-panes", "-t", f"{session_name}:{pane_id}", "-F", "#{pane_active} #{pane_current_command}"],
            universal_newlines=True
        )
        # Output is in the format: "<pane_active> <pane_current_command>"
        for line in output.strip().split("\n"):
            active, command = line.split()
            # Check if the pane is active and not running a long-running command
            if active == "1" and command in ["bash", "zsh", "sh"]:  # Assume idle if shell is running
                return True
        return False
    except subprocess.CalledProcessError as e:
        print(f"Error checking tmux pane: {e}")
        return False


if __name__ == "__main__":
    print(is_tmux_pane_idle("sess-1"))
