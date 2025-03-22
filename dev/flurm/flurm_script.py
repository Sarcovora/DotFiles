import subprocess
import time
from run_scripts.utils import generate_hparam_combinations_for_algorithms, format_hparam_combinations, is_tmux_pane_idle
import argparse
import yaml

NUM_GPUS = 4


def create_tmux_sessions(commands):
    """
    Create tmux sessions and send commands to each session.

    Args:
        commands (list): A list of commands to be executed in separate tmux sessions.
    """
    session_names = []
    for idx, command in enumerate(commands):
        session_name = f"sess-{idx + 1}"
        cuda_device = idx % NUM_GPUS
        try:
            # Kill the session if it already exists
            subprocess.run(["tmux", "kill-session", "-t", session_name], check=False)

            # Create a new tmux session
            subprocess.run(["tmux", "new-session", "-d", "-s", session_name], check=True)

            # Prepare the command with CUDA_VISIBLE_DEVICES
            cuda_command = f"export CUDA_VISIBLE_DEVICES={cuda_device}"

            # Split the full command into separate parts for tmux send-keys
            subprocess.run(["tmux", "send-keys", "-t", session_name, cuda_command, "C-m"], check=True)
            for part in command.split(" && "):
                subprocess.run(["tmux", "send-keys", "-t", session_name, part, "C-m"], check=True)

            print(f"Created tmux session '{session_name}' and sent command: {cuda_command} {command}")

            # Delay the next command by 1.1 seconds
            time.sleep(1.1)
            session_names.append(session_name)
        except subprocess.CalledProcessError as e:
            print(f"Error creating tmux session '{session_name}' or sending command: {e}")
    return session_names


def monitor_tmux_sessions(session_names):
    """
    Monitor tmux sessions and restart idle sessions.

    Args:
        session_names (list): A list of tmux session names.
    """
    while True:
        for session_name in session_names:
            if not is_tmux_pane_idle(session_name):
                print(f"Session '{session_name}' is idle. Restarting...")
                subprocess.run(["tmux", "kill-session", "-t", session_name], check=True)
                subprocess.run(["tmux", "new-session", "-d", "-s", session_name], check=True)
                print(f"Restarted session '{session_name}'")
            time.sleep(10)


def parse_args():
    parser = argparse.ArgumentParser(description="Run experiments on AWS")
    parser.add_argument("--config", default='', help="Monitor tmux sessions")
    return parser.parse_args()


def get_parm_dicts(yaml_file):
    with open(yaml_file, 'r') as file:
        try:
            hparams = yaml.safe_load(file)
            listed_hparams = {key : value if isinstance(value, list) else [value] for key, value in hparams.items()}

        except yaml.YAMLError as exc:
            print(exc)

    return listed_hparams


if __name__ == "__main__":
    args = parse_args()
    param_dict = get_parm_dicts(args.config)
    algorithm_hparams = [param_dict]

    all_combinations = generate_hparam_combinations_for_algorithms(algorithm_hparams)
    formatted_combinations = format_hparam_combinations(all_combinations)
    cmds = []
    for algorithm, combinations in enumerate(formatted_combinations):
        for idx, combo in enumerate(combinations):
            cmd = f"python main.py {combo}"
            cmds.append(cmd)

    session_names = create_tmux_sessions(cmds)


###################### IQL Training Flurm #############################
# {
#     'dataset_num': ['gaus1_6k', 'eps1_6k', 'eps3_6k', 'gaus3_6k',],
#     'train_iql': [True],
#     'project' : ['amazon-iql-models' ],
#     'dataset_base': ['/efs/sidrud/bremen_datasets/halfcheetah/'],
# }

###################### dynamics training flurm ##########################

# {
#     'dataset_num': ['gaus3'],
#     'train_dynamics': [True],
#     'dynamics.train_steps': [5000],
#     'project': ['amazon-dynamics-models'],
#     'dynamics.activation': ['silu'],
#     'dynamics.model_type': ['no_prob'],
#     'dataset_base': ['/efs/sidrud/bremen_datasets/halfcheetah/'],
# }

###################### energy training flurm ###########################

# {
#     'dataset_num': ['gaus1', 'eps1', 'eps3', 'gaus3', 'random'],
#     'train_energy': [True],
#     'project': ['amazon-energy-models'],
#     'dataset_base': ['/efs/sidrud/bremen_datasets/halfcheetah/'],
# }

###################### iql finetuning test flurm ##########################
# {
#     'expl_policy': ['epsilon_greedy'],
#     'base_dynamics_path':['/efs/sidrud/forward_models/forward_dataset_0/model_ensemble.pt' ],
#     'base_policy_path':['/home/ubuntu/maxrudy/documents/online-expl/sidrud/base_policies_updated_attr/iql/halfcheetah/model_dataset_0.pt'],
#     'dataset_num': [0],
#     'expl_policy.epsilon': [0.1, 0.3],
#     'test_dataset_num': [0], #[2,4],
#     'name': ['epsilon_greedy_test_long_train'],
#     'seed': [0,1],
#     'exploration_steps': [10], #[10_000, 50_000, 100_000],
#     'exploration_iterations': [10],
#     'mix_ratio': [0.0001],
#     'dynamics.train_steps': [20], # so we don't waste time training dynamics
#     'energy.train_steps': [20], # so we don't waste time training energy model
#     'test_dataset_exploration': [False],
#     'rl.reset_final_layer': [False],
#     'finetune_num_steps': [200_000],
# }


################ MPPI test flurm ############################

# {
#         'expl_policy': ['epsilon_greedy'],
#         'base_policy_path': ['/efs/sidrud/base_policies/halfcheetah/iql/model_0.pt'],
#         'base_dynamics_path': ['/efs/sidrud/forward_models/forward_dataset_gaus3/model_ensemble.pt',
#                                '/efs/sidrud/forward_models/forward_dataset_eps3/model_ensemble.pt',
#                                '/efs/sidrud/forward_models/forward_dataset_gaus1/model_ensemble.pt',
#                                '/efs/sidrud/forward_models/forward_dataset_gaus3/model_ensemble.pt',
#                                '/efs/sidrud/forward_models/forward_dataset_random/model_ensemble.pt',],
#         'dataset_num': ['eps1'],
#         'mppi.num_control_samples': [100, 1000, 10000],
#         'mppi.use_ground_truth_dynamics': [False],
#         'mppi.horizon': [10, 15, 20],
#         'eval.mpc.type': ['mppi'],
#         'explore': [False],
# }
