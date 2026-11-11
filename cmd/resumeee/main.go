// Package main provides the orchestration CLI for the Resumeee flagship distribution.
// It manages multi-container Docker deployment lifecycle (up, down, status, logs)
// across the Resumeee service fleet (API server, Web SPA, and database persistence).
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
)

var (
	// Version denotes the application semantic release version.
	Version = "0.1.0-dev"
	// Commit denotes the Git commit SHA from build time.
	Commit = "unknown"
	// BuildDate denotes the ISO timestamp of binary compilation.
	BuildDate = "unknown"
)

// AppInfo encapsulates version and ecosystem repository metadata for Resumeee.
type AppInfo struct {
	Name        string            `json:"name"`
	Version     string            `json:"version"`
	Commit      string            `json:"commit"`
	BuildDate   string            `json:"build_date"`
	Ecosystem   map[string]string `json:"ecosystem"`
}

// CommandRunner abstracts execution of external shell commands for testability.
type CommandRunner func(ctx context.Context, stdout, stderr io.Writer, name string, args ...string) error

// defaultRunner executes system commands directly via os/exec.
func defaultRunner(ctx context.Context, stdout, stderr io.Writer, name string, args ...string) error {
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Stdout = stdout
	cmd.Stderr = stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	if err := run(ctx, defaultRunner, os.Stdout, os.Stderr, os.Args[1:]...); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, runner CommandRunner, stdout, stderr io.Writer, args ...string) error {
	if len(args) == 0 {
		printUsage(stdout)
		return nil
	}

	command := strings.ToLower(strings.TrimSpace(args[0]))
	switch command {
	case "version", "--version", "-v":
		return printVersion(stdout)
	case "help", "--help", "-h":
		printUsage(stdout)
		return nil
	case "up", "start":
		return runComposeUp(ctx, runner, stdout, stderr, args[1:]...)
	case "down", "stop":
		return runComposeDown(ctx, runner, stdout, stderr, args[1:]...)
	case "ps", "status":
		return runComposePS(ctx, runner, stdout, stderr, args[1:]...)
	case "logs":
		return runComposeLogs(ctx, runner, stdout, stderr, args[1:]...)
	default:
		return fmt.Errorf("unknown command %q (run 'resumeee help' for available commands)", command)
	}
}

func printUsage(w io.Writer) {
	_, _ = fmt.Fprintln(w, "Resumeee — AI-Powered Career Profile & Targeted Resume Tailoring Engine")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "Usage:")
	_, _ = fmt.Fprintln(w, "  resumeee <command> [options]")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "Docker Orchestration Commands:")
	_, _ = fmt.Fprintln(w, "  up          Launch all Resumeee services via Docker Compose")
	_, _ = fmt.Fprintln(w, "  down        Stop and clean up all Resumeee Docker containers")
	_, _ = fmt.Fprintln(w, "  status      Check the running status of containerized services")
	_, _ = fmt.Fprintln(w, "  logs        Stream live log output from all services")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "General Commands:")
	_, _ = fmt.Fprintln(w, "  version     Display binary version, commit, and ecosystem metadata")
	_, _ = fmt.Fprintln(w, "  help        Display this help message")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "Options for 'up':")
	_, _ = fmt.Fprintln(w, "  --dev       Use local development compose (docker-compose.dev.yml)")
	_, _ = fmt.Fprintln(w, "  --build     Force rebuilding container images before starting")
	_, _ = fmt.Fprintln(w, "  -d          Run containers in background detached mode (default: true)")
}

func printVersion(w io.Writer) error {
	info := AppInfo{
		Name:      "resumeee",
		Version:   Version,
		Commit:    Commit,
		BuildDate: BuildDate,
		Ecosystem: map[string]string{
			"resumeee-core":          "github.com/resumeee-app/resumeee-core",
			"resumeee-llm":           "github.com/resumeee-app/resumeee-llm",
			"resumeee-storage-sql":   "github.com/resumeee-app/resumeee-storage-sql",
			"resumeee-auth-firebase": "github.com/resumeee-app/resumeee-auth-firebase",
			"resumeee-api":           "github.com/resumeee-app/resumeee-api",
			"resumeee-web":           "github.com/resumeee-app/resumeee-web",
		},
	}
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(info)
}

func composeFileForDev(isDev bool) string {
	if isDev {
		return "docker-compose.dev.yml"
	}
	return "docker-compose.yml"
}

func runComposeUp(ctx context.Context, runner CommandRunner, stdout, stderr io.Writer, args ...string) error {
	fs := flag.NewFlagSet("resumeee up", flag.ContinueOnError)
	fs.SetOutput(stderr)

	var (
		devMode   bool
		buildMode bool
		detach    bool
	)

	fs.BoolVar(&devMode, "dev", false, "Use local docker-compose.dev.yml")
	fs.BoolVar(&buildMode, "build", false, "Rebuild images before starting")
	fs.BoolVar(&detach, "d", true, "Run in detached mode")

	if err := fs.Parse(args); err != nil {
		return err
	}

	composeFile := composeFileForDev(devMode)
	cmdArgs := []string{"compose", "-f", composeFile, "up"}
	if detach {
		cmdArgs = append(cmdArgs, "-d")
	}
	if buildMode {
		cmdArgs = append(cmdArgs, "--build")
	}

	_, _ = fmt.Fprintf(stdout, "Bringing up Resumeee services with %s...\n", composeFile)
	return runner(ctx, stdout, stderr, "docker", cmdArgs...)
}

func runComposeDown(ctx context.Context, runner CommandRunner, stdout, stderr io.Writer, args ...string) error {
	fs := flag.NewFlagSet("resumeee down", flag.ContinueOnError)
	fs.SetOutput(stderr)

	var devMode bool
	fs.BoolVar(&devMode, "dev", false, "Use local docker-compose.dev.yml")

	if err := fs.Parse(args); err != nil {
		return err
	}

	composeFile := composeFileForDev(devMode)
	_, _ = fmt.Fprintf(stdout, "Shutting down Resumeee services with %s...\n", composeFile)
	return runner(ctx, stdout, stderr, "docker", "compose", "-f", composeFile, "down")
}

func runComposePS(ctx context.Context, runner CommandRunner, stdout, stderr io.Writer, args ...string) error {
	fs := flag.NewFlagSet("resumeee status", flag.ContinueOnError)
	fs.SetOutput(stderr)

	var devMode bool
	fs.BoolVar(&devMode, "dev", false, "Use local docker-compose.dev.yml")

	if err := fs.Parse(args); err != nil {
		return err
	}

	composeFile := composeFileForDev(devMode)
	return runner(ctx, stdout, stderr, "docker", "compose", "-f", composeFile, "ps")
}

func runComposeLogs(ctx context.Context, runner CommandRunner, stdout, stderr io.Writer, args ...string) error {
	fs := flag.NewFlagSet("resumeee logs", flag.ContinueOnError)
	fs.SetOutput(stderr)

	var devMode bool
	fs.BoolVar(&devMode, "dev", false, "Use local docker-compose.dev.yml")

	if err := fs.Parse(args); err != nil {
		return err
	}

	composeFile := composeFileForDev(devMode)
	cmdArgs := []string{"compose", "-f", composeFile, "logs"}
	cmdArgs = append(cmdArgs, fs.Args()...)
	return runner(ctx, stdout, stderr, "docker", cmdArgs...)
}
