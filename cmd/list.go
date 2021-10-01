package cmd

import (
	"github.com/nesl247/jp/pkg/projects"
	"github.com/spf13/cobra"
)

var listCommand = &cobra.Command{
	Use:   "list",
	Short: "List all available projects",
	RunE: func(cmd *cobra.Command, args []string) error {
		var projects, _ = projects.Load()

		projects.List()

		return nil
	},
}
