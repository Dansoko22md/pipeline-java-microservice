package tn.esprit.devops.services;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tn.esprit.devops.entities.Client;
import tn.esprit.devops.repositories.IClientRepository;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class ServicesImpl implements IServices {
    @Autowired
    private  IClientRepository clientRepository;

    @Override
    public Client add(Client client) {
        return clientRepository.save(client);
    }
    @Override
    public List<Client> getAllClients() {
        return clientRepository.findAll();
    }
    @Override
    public void deleteClient(Long id) {
        clientRepository.deleteById(id);
    }

    @Override
    public Client getClientById(Long id) {
        Optional<Client> client = clientRepository.findById(id);
        return client.orElse(null);  // retourne null si client non trouvé
    }



    // add method remove to this class
    public void remove(Client client) {
        clientRepository.delete(client);
    }

    //ajoute la méthode recherche client par id
    public Client findById(Long id) {
        return clientRepository.findById(id).orElse(null);
    }
//Ajoute une methode update
    public Client update(Client client) {
        return clientRepository.save(client);
    }

    //affectation d'un client à un compte


}
