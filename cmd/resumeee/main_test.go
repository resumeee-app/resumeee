package main

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"strings"
	"testing"
)

type recordedCommand struct {
	name string
	args []string
}

func mockRunner(recorded *[]recordedCommand) CommandRunner {
	return func(_ context.Context, _ io.Writer, _ io.Writer, name string, args ...string) error {
		*recorded = append(*recorded, recordedCommand{
			name: name,
			args: args,
		})
		return nil
	}
}

func TestCLI_PrintUsage(t *testing.T) {
	buf := &bytes.Buffer{}
	printUsage(buf)

	output := buf.String()
	if !strings.Contains(output, "Resumeee") {
		t.Errorf("expected usage output to contain 'Resumeee', got: %s", output)
	}
	if !strings.Contains(output, "up") || !strings.Contains(output, "down") {
		t.Errorf("expected usage output to contain 'up' and 'down', got: %s", output)
	}
}

func TestCLI_PrintVersion(t *testing.T) {
	buf := &bytes.Buffer{}
	err := printVersion(buf)
	if err != nil {
		t.Fatalf("unexpected error printing version: %v", err)
	}

	var info AppInfo
	if err := json.Unmarshal(buf.Bytes(), &info); err != nil {
		t.Fatalf("failed to parse version output as JSON: %v, raw: %s", err, buf.String())
	}

	if info.Name != "resumeee" {
		t.Errorf("expected app name 'resumeee', got %q", info.Name)
	}
	if info.Ecosystem["resumeee-core"] != "github.com/resumeee-app/resumeee-core" {
		t.Errorf("missing or incorrect resumeee-core mapping in ecosystem")
	}
	if info.Ecosystem["resumeee-llm"] != "github.com/resumeee-app/resumeee-llm" {
		t.Errorf("missing or incorrect resumeee-llm mapping in ecosystem")
	}
	if info.Ecosystem["resumeee-web"] != "github.com/resumeee-app/resumeee-web" {
		t.Errorf("missing or incorrect resumeee-web mapping in ecosystem")
	}
}

func TestCLI_Run_UnknownCommand(t *testing.T) {
	ctx := context.Background()
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	var cmds []recordedCommand
	runner := mockRunner(&cmds)

	err := run(ctx, runner, stdout, stderr, "nonexistent-cmd")
	if err == nil {
		t.Fatal("expected error on unknown command, got nil")
	}
	if !strings.Contains(err.Error(), "unknown command") {
		t.Errorf("expected unknown command error message, got: %v", err)
	}
}

func TestCLI_Run_ComposeUp_Production(t *testing.T) {
	ctx := context.Background()
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	var cmds []recordedCommand
	runner := mockRunner(&cmds)

	err := run(ctx, runner, stdout, stderr, "up")
	if err != nil {
		t.Fatalf("unexpected error running compose up: %v", err)
	}

	if len(cmds) != 1 {
		t.Fatalf("expected 1 command executed, got %d", len(cmds))
	}
	cmd := cmds[0]
	if cmd.name != "docker" {
		t.Errorf("expected command 'docker', got %q", cmd.name)
	}
	expectedArgs := []string{"compose", "-f", "docker-compose.yml", "up", "-d"}
	if strings.Join(cmd.args, " ") != strings.Join(expectedArgs, " ") {
		t.Errorf("expected args %v, got %v", expectedArgs, cmd.args)
	}
}

func TestCLI_Run_ComposeUp_DevMode(t *testing.T) {
	ctx := context.Background()
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	var cmds []recordedCommand
	runner := mockRunner(&cmds)

	err := run(ctx, runner, stdout, stderr, "up", "--dev", "--build")
	if err != nil {
		t.Fatalf("unexpected error running compose up dev: %v", err)
	}

	if len(cmds) != 1 {
		t.Fatalf("expected 1 command executed, got %d", len(cmds))
	}
	cmd := cmds[0]
	expectedArgs := []string{"compose", "-f", "docker-compose.dev.yml", "up", "-d", "--build"}
	if strings.Join(cmd.args, " ") != strings.Join(expectedArgs, " ") {
		t.Errorf("expected args %v, got %v", expectedArgs, cmd.args)
	}
}

func TestCLI_Run_ComposeDown(t *testing.T) {
	ctx := context.Background()
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	var cmds []recordedCommand
	runner := mockRunner(&cmds)

	err := run(ctx, runner, stdout, stderr, "down")
	if err != nil {
		t.Fatalf("unexpected error running compose down: %v", err)
	}

	if len(cmds) != 1 {
		t.Fatalf("expected 1 command executed, got %d", len(cmds))
	}
	cmd := cmds[0]
	expectedArgs := []string{"compose", "-f", "docker-compose.yml", "down"}
	if strings.Join(cmd.args, " ") != strings.Join(expectedArgs, " ") {
		t.Errorf("expected args %v, got %v", expectedArgs, cmd.args)
	}
}

func TestCLI_Run_ComposeStatus(t *testing.T) {
	ctx := context.Background()
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	var cmds []recordedCommand
	runner := mockRunner(&cmds)

	err := run(ctx, runner, stdout, stderr, "status", "--dev")
	if err != nil {
		t.Fatalf("unexpected error running compose status: %v", err)
	}

	if len(cmds) != 1 {
		t.Fatalf("expected 1 command executed, got %d", len(cmds))
	}
	cmd := cmds[0]
	expectedArgs := []string{"compose", "-f", "docker-compose.dev.yml", "ps"}
	if strings.Join(cmd.args, " ") != strings.Join(expectedArgs, " ") {
		t.Errorf("expected args %v, got %v", expectedArgs, cmd.args)
	}
}
