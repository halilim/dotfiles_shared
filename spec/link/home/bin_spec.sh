Describe 'bin/*'
  Example 'are executable'
    for file in link/home/bin/*; do
      if [[ $file == *functions* || $file == */mine ]]; then
        continue
      fi

      The file "$file" should be executable
    done
  End
End
