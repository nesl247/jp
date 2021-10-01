package cmd

import (
	"fmt"
	"github.com/nesl247/jp/pkg/projects"
	"github.com/sahilm/fuzzy"
	"github.com/spf13/cobra"
)

var (
	rootCmd = &cobra.Command{
		Use:   "jp <project>",
		Short: "A CLI tool to open matching projects",
		Args:  cobra.RangeArgs(0, 1),
		ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
			projects, _ := projects.Load()
			validArgs := make([]string, 0)

			for i := range projects {
				validArgs = append(validArgs, projects[i].FullName)
			}

			for _, arg := range args {
				validArgs = append(validArgs, arg)
			}

			return validArgs, cobra.ShellCompDirectiveNoFileComp & cobra.ShellCompDirectiveNoSpace & cobra.ShellCompDirectiveFilterDirs

		},
		CompletionOptions: cobra.CompletionOptions{
			DisableDefaultCmd:   false,
			DisableNoDescFlag:   false,
			DisableDescriptions: false,
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				err := cmd.UsageFunc()(cmd)
				if err != nil {
					return err
				}

				return nil
			}

			var projects, _ = projects.Load()

			matches := fuzzy.FindFrom(args[0], projects)

			for _, match := range matches {
				fmt.Println("Project:", projects[match.Index].Path)
				break
			}

			return nil
		},
	}
)

// Execute executes the root command.
func Execute() error {
	rootCmd.AddCommand(updateCommand)
	rootCmd.AddCommand(listCommand)

	return rootCmd.Execute()
}
