Describe 'bin/*'
  Example 'are executable'
    for file in link_home/bin/*; do
      if [[ $file == *functions* ]]; then
        continue
      fi

      The file "$file" should be executable
    done
  End
End
