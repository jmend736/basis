function! bss#tmpl#java#ProcExperiment() abort
  let l:Makefile =<< eval trim END
  .PHONY: all
  all:
  	javac Proc.java
  	javac -XprintRounds -processor Proc A.java
  END
  let l:ProcJava =<< eval trim END
  import java.util.Set;
  import javax.annotation.processing.AbstractProcessor;
  import javax.annotation.processing.RoundEnvironment;
  import javax.lang.model.SourceVersion;
  import javax.lang.model.element.TypeElement;

  public class Proc extends AbstractProcessor {{
    @Override
    public Set<String> getSupportedAnnotationTypes() {{
      // Example: "com.example.Outer.Inner"
      return Set.of("*");
    }}

    @Override
    public SourceVersion getSupportedSourceVersion() {{
      return SourceVersion.latestSupported();
    }}

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {{
      return false;
    }}
  }}
  END
  let l:AJava =<< eval trim END
  public interface A {{
    int f(int x);
    int g(int x);
  }}
  END
  call bss#tmpl#Write({
        \   'Makefile': l:Makefile,
        \   'Proc.java': l:ProcJava,
        \   'A.java': l:AJava,
        \ })
endfunction

function! bss#tmpl#java#BasicMainContent(package, classname) abort
  let lines =<< eval trim END
    package {a:package};

    public class {a:classname} {{
      public static void main(String[] args) {{
        System.out.println("Hello, world!");
      }}
    }}
  END
  return lines
endfunction

function! bss#tmpl#java#BasicMainTestContent(package, classname) abort
  let lines =<< eval trim END
    package {a:package};

    import static com.google.common.truth.Truth.assertThat;

    import org.junit.Test;

    public class {a:classname}Test {{
      @Test
      public void actionTaken_expectedResult() {{
        assertThat(true).isFalse();
      }}
    }}
  END
  return lines
endfunction
