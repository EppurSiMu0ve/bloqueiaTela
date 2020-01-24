# bloqueiaTela
i3lock te permite bloquear a tela com uma interface plana e simples. Esse script usa o i3lock para congelar
sua tela com um ícone aleatório (você deve especificar a pasta com os ícones como parâmetro) e adiciona na tela de 
bloqueio um texto que solicita ao usuário a senha para desbloqueio.

Uso: <b>$	bloqueiaTela.sh </i>dir-icons</i></b>

		dir-icons
				: é o diretório que contém as
				: os ícones .png que você deseja
				: exibir na tela de bloqueio.

# Olha como ficou!!
![bloquando](https://raw.githubusercontent.com/EppurSiMu0ve/bloqueiaTela/master/20200121-021812.avi.gif)



	DICAS
		: talvez você queira alterar o texto exibido
		: na tela de bloqueio ou algumas de suas propriedades,
		: já que estão codificadas para resolução 1920x1080.
		: Por isso deixei as indicações <<---------------| Alterar propriedades se necessário |---
	ATALHO NO I3WM
		: inserir tecla de atalho no arquivo de
		: configuração do i3 (~/.config/i3/config)
		: que execute esse script.
		: Exemplo:
		: bindsym $mod+l exec /caminho/do/bloqueiaTela.sh /diretorio/de/iconesPng
		: exec --no-startup-id xautolock -time 2 -locker "/caminho/bloqueiaTela.sh /diretorio/iconesPng" &
	ERROS DE EXECUÇÃO
		: Os erros de execução do script serão
		: gravados no arquivo $HOME/ErroBloqueioTela.
