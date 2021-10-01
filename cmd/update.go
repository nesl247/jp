package cmd

import (
	"github.com/nesl247/jp/pkg/projects"
	"github.com/spf13/cobra"
)

var verbose = false

var updateCommand = &cobra.Command{
	Use:   "update",
	Short: "Update the project list",
	RunE: func(cmd *cobra.Command, args []string) error {
		_, err := projects.Update(verbose)
		if err != nil {
			return err
		}

		return nil
	},
}

func init() {
	updateCommand.Flags().BoolVarP(&verbose, "verbose", "v", false, "Display the projects after updating")
}
