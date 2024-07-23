# Devset

A bash script created to set up local web environments. It automates the configuration of Nginx and PHP-FPM, creating a local domain (.test) to view these projects.

This project was created mostly to practice bash. If you want more robust solutions, I recommend **[DDEV](https://ddev.com/)**, **[Valet Linux](https://github.com/cpriego/valet-linux)**, or **[Laravel Herd](https://herd.laravel.com/)** *(if you're on Mac/Windows)*.

## Installation

Using curl:
```bash
sudo curl -L -o /usr/local/bin/devset https://raw.githubusercontent.com/rodrigomantoan/devset/main/devset.sh && sudo chmod +x /usr/local/bin/devset
```

Using wget:
```bash
sudo wget -O /usr/local/bin/devset https://raw.githubusercontent.com/rodrigomantoan/devset/main/devset.sh && sudo chmod +x /usr/local/bin/devset
```

*Restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc` if you're using zsh).*

## Usage

### Creating a new project

To create a new project, use the following command:

```bash
devset create project_name --project_type
```

The `--project_type` flag is optional and can be one of the following: `wordpress`, `laravel`, or `statamic`. 
If you don't provide a project type, Devset will assume it's a generic PHP project _(you can define a public folder)_.

### Removing a project

To remove a project, use the following command:

```bash
devset remove project_name
```

You will be prompted to confirm the removal of configurations and project files.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.