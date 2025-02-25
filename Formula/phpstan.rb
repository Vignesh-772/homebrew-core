class Phpstan < Formula
  desc "PHP Static Analysis Tool"
  homepage "https://github.com/phpstan/phpstan"
  url "https://github.com/phpstan/phpstan/releases/download/1.10.11/phpstan.phar"
  sha256 "b3ccc1bcd2e84a8d064961bf624122bc99fbbc0a8e64bcfe26686f6b351b2656"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5789770fa4c719bf622985d23b1ee46fae8dff1240c289b55c98fdcbdc8b67fa"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5789770fa4c719bf622985d23b1ee46fae8dff1240c289b55c98fdcbdc8b67fa"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "5789770fa4c719bf622985d23b1ee46fae8dff1240c289b55c98fdcbdc8b67fa"
    sha256 cellar: :any_skip_relocation, ventura:        "35bff9dbe386b9084c5951dbb06468f37409523a0504c212177a25fbfe6015b4"
    sha256 cellar: :any_skip_relocation, monterey:       "35bff9dbe386b9084c5951dbb06468f37409523a0504c212177a25fbfe6015b4"
    sha256 cellar: :any_skip_relocation, big_sur:        "35bff9dbe386b9084c5951dbb06468f37409523a0504c212177a25fbfe6015b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5789770fa4c719bf622985d23b1ee46fae8dff1240c289b55c98fdcbdc8b67fa"
  end

  depends_on "php" => :test

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "phpstan.phar" => "phpstan"
  end

  test do
    (testpath/"src/autoload.php").write <<~EOS
      <?php
      spl_autoload_register(
          function($class) {
              static $classes = null;
              if ($classes === null) {
                  $classes = array(
                      'email' => '/Email.php'
                  );
              }
              $cn = strtolower($class);
              if (isset($classes[$cn])) {
                  require __DIR__ . $classes[$cn];
              }
          },
          true,
          false
      );
    EOS

    (testpath/"src/Email.php").write <<~EOS
      <?php
        declare(strict_types=1);

        final class Email
        {
            private string $email;

            private function __construct(string $email)
            {
                $this->ensureIsValidEmail($email);

                $this->email = $email;
            }

            public static function fromString(string $email): self
            {
                return new self($email);
            }

            public function __toString(): string
            {
                return $this->email;
            }

            private function ensureIsValidEmail(string $email): void
            {
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    throw new InvalidArgumentException(
                        sprintf(
                            '"%s" is not a valid email address',
                            $email
                        )
                    );
                }
            }
        }
    EOS
    assert_match(/^\n \[OK\] No errors/,
      shell_output("#{bin}/phpstan analyse --level max --autoload-file src/autoload.php src/Email.php"))
  end
end
