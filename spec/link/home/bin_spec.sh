Describe 'bin/*'
  Example 'are executable'
    for file in link/home/bin/*; do
      The file "$file" should be executable
    done
  End
End
