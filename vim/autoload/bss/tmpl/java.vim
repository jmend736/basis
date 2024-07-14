function! bss#tmpl#java#BasicMainContent(package, classname) abort
  let lines =<< eval trim END
    package {package};

    public class {classname} {{
      public static void main(String[] args) {{
        System.out.println("Hello, world!");
      }}
    }}
  END
  return lines
endfunction

function! bss#tmpl#java#BasicMainTestContent(package, classname) abort
  let lines =<< eval trim END
    package {package};

    import static com.google.common.truth.Truth.assertThat;

    import org.junit.Test;

    public class {classname}Test {{
      @Test
      public void actionTaken_expectedResult() {{
        assertThat(true).isFalse();
      }}
    }}
  END
  return lines
endfunction
